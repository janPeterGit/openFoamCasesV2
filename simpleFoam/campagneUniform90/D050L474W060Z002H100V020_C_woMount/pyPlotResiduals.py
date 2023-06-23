import matplotlib.pyplot as plt

# Read data from file
data = []
final_cols = []
with open("postProcessing/solverInfo/0/solverInfo.dat", "r") as f:
    headers = f.readline().strip().split()
    for i, header in enumerate(headers):
        if "_final" in header:
            final_cols.append(i)
    for line in f:
        line = line.strip().split()
        data.append(line)

# Extract time and final value columns
time = [int(item[0]) for item in data]
final_values = [[float(item[col]) for item in data] for col in final_cols]

# Plot data
for values in final_values:
    plt.plot(time, values)
plt.xlabel("Time or Iteration")
plt.ylabel("Residual")
plt.legend([headers[col] for col in final_cols])
plt.show()
