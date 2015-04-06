total_students = int(raw_input())
matrix = []

for i in range(total_students):
    row = raw_input()
    matrix.append([c.lower() for c in row])

info, possibilities = 0, 0.0
rng = range(total_students)

# Get total numbers of possibilities first
for i in rng:
    possibilities += len([elt for elt in matrix[i] if elt == 'y'])

# Calculate viable options
for i in rng:
    if 'y' in matrix[i]:
        for j in rng:
            if matrix[i][j] == 'y':
                info += 1
                matrix[j][i] = 'n'
    else:
        break

# Prevent division by zero error
if info == 0:
    info = 1
    print(info)
else:
    print(possibilities/info)
