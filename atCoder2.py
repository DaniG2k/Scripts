s = raw_input().split()
a, b, x, k, m = int(s[0]), int(s[1]), int(s[2]), int(s[3]), int(s[4])

rng = range(k-1,k+5)
for i in xrange(0, max(rng)):
    result = (a*x+b)%m
    if i in rng:
        print(x)
    x = result
