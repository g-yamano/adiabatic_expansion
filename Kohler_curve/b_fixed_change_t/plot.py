import matplotlib.pyplot as plt
import glob
import re
import os

def read_kohler_data(filename):
    x_axis_data = []
    y_axis_data = []
    try:
        with open(filename, 'r') as f:
            for line in f:
                parts = line.strip().split()
                if not parts:
                    continue
                if len(parts) == 2:
                    try:
                        x_val = float(parts[0])
                        y_val = float(parts[1])
                        x_axis_data.append(x_val)
                        y_axis_data.append(y_val)
                    except ValueError:
                        continue
    except Exception as e:
        print(f"Error reading {filename}: {e}")
        return None, None
    
    if not x_axis_data:
        return None, None
        
    return x_axis_data, y_axis_data

def plot_single(x, y, temp_label, save_filename):
    plt.figure(figsize=(10, 6))
    plt.plot(x, y, linestyle='-', label=f'T = {temp_label}')
    plt.xscale('log')
    plt.xlabel("Radius [µm]")
    plt.ylabel("Relative humidity [%]")
    plt.title(f"Köhler curve ({temp_label})")
    plt.grid(True)
    plt.legend()
    try:
        plt.savefig(save_filename, dpi=300)
        print(f"Saved: {save_filename}")
    except Exception as e:
        print(f"Error saving {save_filename}: {e}")
    plt.close()

def plot_combined(data_dict, save_filename="kohler_combined.jpg"):
    plt.figure(figsize=(10, 6))
    
    # Sort by temperature (extract number from label "40℃")
    sorted_keys = sorted(data_dict.keys(), key=lambda x: int(re.search(r'\d+', x).group()) if re.search(r'\d+', x) else 0)
    
    for label in sorted_keys:
        x, y = data_dict[label]
        plt.plot(x, y, linestyle='-', label=label)
        
    plt.xscale('log')
    plt.xlabel("Radius [µm]")
    plt.ylabel("Relative humidity [%]")
    plt.title("Köhler curve (Temperature dependence)")
    plt.grid(True)
    plt.legend()
    try:
        plt.savefig(save_filename, dpi=300)
        print(f"Saved combined graph: {save_filename}")
    except Exception as e:
        print(f"Error saving {save_filename}: {e}")
    plt.close()

def main():
    # Find all kohler_*.dat files (e.g., kohler_40C.dat)
    files = glob.glob("kohler_*C.dat")
    if not files:
        print("No kohler data files found matching pattern 'kohler_*C.dat'.")
        return

    all_data = {}

    for filename in files:
        # Extract temperature from filename
        match = re.search(r'kohler_(\d+)C\.dat', filename)
        if match:
            temp_val = match.group(1)
            label = f"{temp_val}℃"
        else:
            label = filename

        print(f"Processing {filename}...")
        x, y = read_kohler_data(filename)
        
        if x and y:
            # Save individual plot
            plot_single(x, y, label, filename.replace('.dat', '.jpg'))
            # Store for combined plot
            all_data[label] = (x, y)

    if all_data:
        plot_combined(all_data)

if __name__ == "__main__":
    main()