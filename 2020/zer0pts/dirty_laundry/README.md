# dirty laundry Writeup

### zer0pts CTF 2020 - crypto 636

> Do you wanna air my dirty laundry?

#### Observations

[Paillier cryptosystem](https://en.wikipedia.org/wiki/Paillier_cryptosystem) with [Shamir's secret sharing](https://en.wikipedia.org/wiki/Shamir%27s_Secret_Sharing) is given to me. The algorithms for the system are summarized below.

0. Let `secret = bytes_to_long(flag)`
1. 1024 bit strong prime `PRIME` is chosen.
2. Lower 256 bit of `PRIME` will be the initial `seed` of prng(`PRNG256`) having output size of 256 bits.
3. Polynomial `f(x) = secret + a * x + b * x ** 2 (mod PRIME)` is generated. `a` and `b` are randomly choosn in `GF(PRIME)`.
4. Public key `n`, `g` and ciphertext `c` is generated and exposed. Iterate below five times, by changing `x in range(1, 6)`.
    - `noise`, `key`, and `r` is produced from `PRNG256`, having size of 256 bits.
    - `n = next_prime(PRIME + noise) * getStrongPrime(512)`, having size of 1024 + 512 = 1536 bits.
    - `g = (1 + key * n) % n ** 2`, having max size of 256 + 1536 = 1792
    - `c = pow(g, f(x) + noise, n ** 2) * pow(r, n, n ** 2) % n ** 2`

#### Gaining information gradually by mathematics

1. Recover `key` values
    - Observe the generation method for `g = (1 + key * n) % n ** 2`. There is no point of modulo division of `n ** 2` because `1 + key * n` has at most 1792 bit length, but `n ** 2` has length of 1536 * 2 = 3072 bits.
    - Therefore, by knowing `g` and `n`, I can calculate `key = (g - 1) // n`. Sanity check performed by checking bitlength of `key` is about 256 bits.
2. Break `PRNG256` by z3.
    - `key` is the output of `PRNG256`. Supplying constraints to z3, I could recover initial `seed`, which is 256 LSBs of `PRIME`.
    - Sanity check performed, by comparing next `key` values with outputs generated by `PRNG256` initialized by recovered `seed`.
3. Reduce solving systems of equations over `GF(PRIME)`.
    - `c = pow(g, f(x) + noise, n ** 2) * pow(r, n, n ** 2) % n ** 2`
    - I now know `r` and `noise` because I broke `PRNG256`.
    - Let `c_ = pow(g, f(x) + noise, n ** 2) = c * inverse_mod(pow(r, n, n ** 2), n ** 2) % n ** 2`
    - `c_ = pow(g, f(x) + noise, n ** 2) = (1 + key * n) ** (f(x) + noise) % n ** 2`
    - Perform binomial expansion. Starting from third term will be divided by `n ** 2`, so simplify the equation.
    - `c_ = 1 + key * n * (secret + a * x + b * x ** 2 + noise) % n ** 2`
    - `noise` is known, so simplify again.
    - Let `c__ = key * n * (secret + a * x + b * x ** 2) = (c_ - 1) * inverse_mod(key * n * noise, n ** 2) % n ** 2`
    - Sanity check of `c__`; it must have max bit length of 256 + 1536 + 1024 = 2816.
    - Luckily, `c__` was dividable by each `n`! Now we do not need to think about operation over `GF`.
4. Solve plain systems of equations.
    - Let `c__[i]` be the result per each `x in range(1, 6)`
    - `c__[0] = secret + a * 1 + b * 1 ** 2 = secret + a + b`
    - `c__[1] = secret + a * 2 + b * 2 ** 2 = secret + 2 * a + 4 * b`
    - `c__[2] = secret + a * 3 + b * 3 ** 2 = secret + 3 * a + 9 * b`
    - I only need three equations because there are three unknown variables, `secret`, `a`, `b`.
    - `secret = c__[0] * 3 + c__[1] * -3 + c__[2] * 1`
    - `flag = l2b(secret)`

I strongly think this solution is unintended, because 256 LSBs of `PRIME` was never used. The system may be broken by using LLL. After all these tedious computations, I finally get the flag:

```
zer0pts{excellent_w0rk!y0u_are_a_master_0f_crypt0!!!}
```

Exploit code: [solve.py](solve.py)

Run with `python3 -O solve.py`