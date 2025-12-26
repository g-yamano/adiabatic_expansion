import matplotlib.pyplot as plt

def plot_data_from_file(filename="kohler.dat", save_filename="kohler.jpg"):
    x_axis_data = []  
    y_axis_data = []  
    try:
        with open(filename, 'r') as f:
            for line_number, line in enumerate(f, 1):
                parts = line.strip().split()

                # 空行の場合、次の行へスキップ (Fortranが出力する空行に対応)
                if not parts:
                    continue

                if len(parts) == 2:
                    try:
                        x_val = float(parts[0])
                        y_val = float(parts[1])
                        
                        x_axis_data.append(x_val)
                        y_axis_data.append(y_val)
                    except ValueError:
                        print(f"警告: {line_number}行目 - 不正なデータ形式のためスキップしました (数値変換エラー): {line.strip()}")
                else:
                    print(f"警告: {line_number}行目 - 列数が不一致のためスキップしました (期待値: 2): {line.strip()}")
    except FileNotFoundError:
        print(f"エラー: ファイル '{filename}' が見つかりませんでした。")
        return
    except Exception as e:
        print(f"ファイル '{filename}' の読み込み中にエラーが発生しました: {e}")
        return

    if not x_axis_data or not y_axis_data:
        print("エラー: グラフをプロットするための有効なデータが読み込まれませんでした。")
        return

    # グラフの作成
    plt.figure(figsize=(10, 6))
    # X軸に半径(x_axis_data)、Y軸に相対湿度(y_axis_data)をプロット
    #plt.plot(x_axis_data, y_axis_data, marker='o', linestyle='-', markersize=0.1)
    plt.plot(x_axis_data, y_axis_data, linestyle='-')
    plt.xscale('log')
    plt.xlabel("Radius [µm]")
    plt.ylabel("Relative humidity [%]")
    plt.title("Köhler curve")

    plt.grid(True)

    try:
        plt.savefig(save_filename, dpi=300)
        print(f"グラフが '{save_filename}' として保存されました。")
    except Exception as e:
        print(f"グラフを '{save_filename}' に保存中にエラーが発生しました: {e}")
        return

    plt.show()

if __name__ == "__main__":
    plot_data_from_file("kohler.dat", "kohler.jpg")