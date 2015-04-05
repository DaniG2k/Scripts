string = raw_input()
dic, newdic = {}, {}

for char in [x for x in string]:
    if char in dic:
        dic[char] += 1
    else:
        dic[char] = 1
        
for key, val in dic.items():
    if val in newdic:
        newdic[val] = newdic[val] + [key]
    else:
        newdic[val] = [key]
        
while any(newdic):
    greatest = max(newdic)
    print(",".join(sorted(newdic[greatest])))
    del(newdic[greatest])
