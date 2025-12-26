import matplotlib.pyplot as plt
import glob
import os

def main():
    # dg_S_*.dat パターンのファイルを取得
    dat_files = glob.glob("dg_S_*.dat")
    dat_files.sort()

    # まとめて表示するためのFigureを作成
    fig_comb, ax_comb = plt.subplots(figsize=(10, 6))

    for filename in dat_files:
        times = []
        radii = []
        
        try:
            with open(filename, 'r') as f:
                for line in f:
                    parts = line.strip().split()
                    if not parts: continue
                    
                    if len(parts) == 2:
                        try:
                            times.append(float(parts[0]))
                            radii.append(float(parts[1]))
                        except ValueError:
                            continue
        except FileNotFoundError:
            continue
        
        if not times:
            continue

        # ファイル名からSとTcの値を抽出してラベルにする
        base_name = filename.replace(".dat", "")
        label_text = base_name
        
        try:
            if "_Tc_" in base_name:
                parts = base_name.split("_Tc_")
                s_part = parts[0] # dg_S_0.990
                tc_part = parts[1] # 60.00
                
                s_val = s_part.replace("dg_S_", "")
                tc_val = tc_part
                label_text = f"S={s_val}, Tc={tc_val}"
            else:
                s_val = base_name.replace("dg_S_", "")
                label_text = f"S={s_val}"
        except:
            pass

        ax_comb.plot(times, radii, marker='o', linestyle='-', markersize=1, label=label_text)

        fig_ind, ax_ind = plt.subplots(figsize=(10, 6))
        ax_ind.plot(times, radii, marker='o', linestyle='-', markersize=1)
        ax_ind.set_xlabel("time [s]")
        ax_ind.set_ylabel("radius [µm]")
        ax_ind.set_title(f"Diffusion Growth ({label_text})")
        ax_ind.grid(True)
        ax_ind.locator_params(axis='x', nbins=20)
        
        ind_save_name = filename.replace(".dat", ".jpg")
        fig_ind.savefig(ind_save_name, dpi=300)
        plt.close(fig_ind) # メモリ解放
        print(f"個別のグラフを保存しました: {ind_save_name}")

    ax_comb.set_xlabel("time [s]")
    ax_comb.set_ylabel("radius [µm]")
    ax_comb.set_title("Diffusion Growth (Combined)")
    ax_comb.grid(True)
    ax_comb.locator_params(axis='x', nbins=20)
    ax_comb.legend()

    comb_save_name = "diffusion_growth_combined.jpg"
    fig_comb.savefig(comb_save_name, dpi=300)
    plt.close(fig_comb)
    print(f"まとめて可視化したグラフを保存しました: {comb_save_name}")

if __name__ == "__main__":
    main()