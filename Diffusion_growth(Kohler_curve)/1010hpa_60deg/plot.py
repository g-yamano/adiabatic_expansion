import matplotlib.pyplot as plt

def plot_data_from_file(filename="dg.dat", save_filename="diffusion_growth.jpg"):
    times = []
    radii = []

    try:
        with open(filename, 'r') as f:
            for line in f:
                parts = line.strip().split()
                
                # 空行の場合、次の行へスキップ
                if not parts:
                    continue 
                
                if len(parts) == 2:
                    try:
                        time = float(parts[0])
                        radius = float(parts[1])
                        times.append(time)
                        radii.append(radius)
                    except ValueError:
                        print(f"警告: 不正なデータ形式の行をスキップしました (数値変換エラー): {line.strip()}")
                else:
                    print(f"警告: 不完全な行をスキップしました (列数不一致): {line.strip()}")
    except FileNotFoundError:
        print(f"エラー: ファイル '{filename}' が見つかりませんでした。")
        return

    if not times or not radii:
        print("エラー: グラフをプロットするためのデータがありません。")
        return

    plt.figure(figsize=(10, 6)) # グラフのサイズを設定
    plt.plot(times, radii, marker='o', linestyle='-', markersize=1) # プロット
    plt.xlabel("time [s]") # 横軸のラベル
    plt.ylabel("radius [µm]") # 縦軸のラベル
    plt.title("Diffusion Growth") # グラフのタイトル
    plt.grid(True) # グリッドを表示
    plt.locator_params(axis='x', nbins=20)

    # グラフをJPEG形式で保存
    plt.savefig(save_filename, dpi=300) # dpiで解像度を指定

    # グラフを画面に表示（不要であればコメントアウト）
    plt.show() 

    print(f"グラフが '{save_filename}' として保存されました。")

if __name__ == "__main__":
    plot_data_from_file("dg.dat", "diffusion_growth.jpg")