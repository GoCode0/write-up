#!/usr/bin/env python3
import z3
import pwn

target = "inctf{U_Sur3_m4Te?}"

input = z3.BitVecs(' '.join(['input_{}'.format(i) for i in range(30)]), 32)
output = [None] * 19

temp = [None] * 22
temp[0] = input[0] - 50 + input[1]
temp[1] = input[1] - 100 + input[2]
temp[2] = 4 * input[2]
temp[3] = input[3] ^ 0x46
temp[4] = 36 - (input[3] - input[4])
temp[6] = (input[6] * input[5] + 99)
temp[7] = (input[6] ^ input[7])
temp[8] = (input[7] + 45) ^ input[8]
temp[9] = (input[9] & 0x37) - 3
temp[11] = input[11] - 38
temp[12] = 4 * ((input[12] ^ input[6]) + 4)
temp[5] = (input[21] - input[4]) ^ 0x30
temp[13] = input[13] - input[14] - 1
temp[10] = input[17] - input[16] + 82
temp[16] = 6 * (input[18] ^ input[19]) + 54
temp[17] = input[21] + 49 + (input[20] ^ 0x73)
temp[14] = input[22]
temp[18] = input[23] ^ 0x42
temp[15] = input[26] + 5
temp[19] = input[25] - input[26] / 2 - 55
temp[20] = 4 * input[27] - (input[28] + 128)
temp[21] = input[29] - 32

output[0] = (temp[0] ^ 2) - 31
output[1] = ((temp[1] % 2) ^ temp[0]) - 29
output[2] = (4 * temp[1]) ^ 0x97
output[3] = temp[2] ^ 0xA0
output[4] = (temp[3] ^ 0x4D) + 7
output[5] = 4 * temp[5] - 1
output[3] = temp[4] + 116
output[6] = temp[6] + 21
output[7] = temp[7] - 20
output[8] = temp[8] ^ 0x63
output[9] = (temp[10] ^ 3) - temp[8] + 54
output[10] = temp[9] ^ 0x42
output[11] = temp[11] + 51
output[11] = temp[12] ^ 0xB3
output[12] = (temp[13] + 18) ^ 0x1A
output[13] = temp[14] - 7
output[14] = temp[15] - 37
output[15] = temp[17] ^ 0xE5
output[16] = (temp[18] & 0x36) + 53
output[14] = temp[19] ^ 0x34
output[17] = temp[20] ^ 0xFD
output[18] = (temp[20] >> temp[21]) ^ 0x1C

S = z3.Solver()
assert len(output) == len(target)
for i in range(len(output)):
    S.add(output[i] & 0xFF == ord(target[i]))

for i in range(len(input)):
    S.add(input[i] < 128)
    S.add(0 < input[i])
    S.add(input[i] != ord(" "))


assert S.check() == z3.sat
ans = S.model()
ans = sorted([(d, ans[d]) for d in ans], key = lambda x: int(str(x[0]).lstrip('input_')))
payload = ""

for _, val in ans:
    payload += chr(int(str(val)))
assert len(payload) == len(input)

pwn.log_level = "DEBUG"
DEBUG = False
if DEBUG:
    p = pwn.process("./find_plut0/chall")
else:
    p = pwn.remote("34.94.181.140", 4205)
p.recvline("Help me call him out please !!")
p.sendline(payload.encode())

flag = "inctf{PluT0_C0m3_&_g3t_y0uR_tr3aToz!}"
p.recvuntil(flag)
pwn.log.success(flag)
p.close()