import re
from functools import reduce
from operator import mul
from random import randint

from Crypto.Util.number import GCD, bytes_to_long, getPrime, isPrime
from sage.all import Integer, Mod, crt, discrete_log

c = 7146993245951509380139759140890681816862856635262037632915667109712467317954902955151177421740994622238561522690931235839733579166121631742096762557444153806131985279962646477997889661633938981817306610901055296705982494607773446985300816341071922739788638126631520234249358834592814880445497817389957300553660499631838091201561728727996660871094966330045071879490277901216751327226984526095495604592577841120425249633624459211547984305731778854596177467026282357094690700361174790351699376317810120824316300666128090632100150965101285647544696152528364989155735157261219949095760495520390692941417167332814540685297

flag_regex = rb"hope{[a-zA-Z0-9_\-]+}"


m = bytes_to_long(b"hope{X}"[::-1])


def gen_prime():
    while True:
        primes = [getPrime(randint(28, 32)) for _ in range(36)]
        res = 2 * reduce(mul, primes) + 1
        if isPrime(res):
            return res, primes


while True:
    p, _ = gen_prime()
    q, _ = gen_prime()

    print(p, q)
    # p = 677661658589234112756465671852737813656545373878218551552799861639215184464373224750162223851960147647870929027499927157390443231467645012934601241993668260362386894881733645172829619601731219933546918176685291214401292287792042762524238406746225742014791099186572744944292057816557573279528072727800070417887373327223
    # q = 4858554757717721092838947140535785436490128233580090253629298212489118123889397212981915537124345329104335478886563993935561723143193201028778168838915315026922729155985178627698819782806901549644560250679381144704911746790475520634540060597593726127675650384591007666889448233985234386687634971814022446964388275419859979
    assert p >= 3 and isPrime(p)
    assert q >= 3 and isPrime(q)
    assert GCD(p, q) == 1

    N = p * q
    assert m < N and c < N

    try:
        d_p = discrete_log(Mod(m % p, p), Mod(c % p, p))
        d_q = discrete_log(Mod(m % q, q), Mod(c % q, q))
    except:
        continue

    d = Integer(crt([d_p, d_q], [p - 1, q - 1]))
    assert pow(c, d, N) == m

    phiN = Integer((p - 1) * (q - 1))
    e = Integer(pow(d, -1, phiN))
    assert e >= 2
    assert GCD(e, phiN) == 1
    assert e <= phiN

    print(p)
    print(q)
    print(e)

    N = p * q
    phiN = (p - 1) * (q - 1)
    d = pow(e, -1, phiN)
    m_recovered = int(pow(c, d, N))
    assert m == m_recovered

    print(int.to_bytes(m_recovered, 256, "little").strip(b"\x00"))
    break


"""
25931336981886917881508651804888771361969756482693247201695599791105032860762590862838821024111901700224643719505231336034502958126084753697080840310691221111632480524959093747695485596846043250396049349666403180602487570953283810801275304729221680667496343520840955737096446034679766231268457472516945103413970777290250987
10797640012008794567838082450444248490192778524474271860736319603579217308877189552312974153242621644750079592406767607411088957521306912494303177039611414073736540194651940148150764332865344104679426425794318083787810388448726356000627919673765464229719310851823901901173392474586055294592050604942248720345228169259692427
251321803495429864603136749934400431095565822624541566866191227318056508010361865159085974249687793093306746531238274627030116316704933243093023256848595710819901698716631502074721726448270326116470497964515622807313788682869572464269504402561876063887571221187625165191081079141521186966806583820816884310266726407236136551918643028735480262079372185761122622387201946889228604553303476788293625573299804705242234929682653178043602731437964238436281412310984154655181705354192023400360227825953412158371148337885773666658916624532116921848292860687764399780984446074959799967426796320581546701246443536248033628192871649827165912848767592537461
"""

# hope{successful_decryption_doesnt_mean_correct_decryption_0363f29466b883edd763dc311716194d37dff5cd93cd4f1b4ac46152f4f9}
# nc mc.ax 31669