# 断熱膨張 / 液滴成長シミュレーションスクリプト

このリポジトリには、様々な条件下での水滴の成長シミュレーションとケーラー曲線の計算を行うためのFortranおよびPythonスクリプトが含まれています。

## ディレクトリ構造

- **Diffusion_growth(Kohler_curve)**: 拡散による液滴成長のシミュレーション。
    - `1010hpa_60deg/`: 1010 hPa、60°Cでのシミュレーション。
        - `diffusion_growth.f90`: メインのシミュレーションコード。時間経過に伴う液滴半径を計算します。
        - `plot.py`: 結果（`dg.dat`）を可視化するスクリプト。
    - `compare_to_analytical_solution(ignore_kohler_curve)/`: 解析解との比較（ケーラー曲線を無視）。
    - `compare_to_tauact_50deg/`: 50°Cでの活性化時間（tau_act）との比較。
    - `compare_to_tauact_60deg/`: 60°Cでの活性化時間（tau_act）との比較。
    - `compare_to_tauact_70deg/`: 70°Cでの活性化時間（tau_act）との比較。
    - `tc_50_change_s/`: 50°Cで飽和度（S）を変化させたシミュレーション。
    - `tc_60_change_s/`: 60°Cで飽和度（S）を変化させたシミュレーション。
        - `diffusion_growth.f90`: メインのシミュレーションコード。
        - `plot.py`: 結果を可視化するスクリプト。
    - `tc_70_change_s/`: 70°Cで飽和度（S）を変化させたシミュレーション。

- **Kohler_curve**: ケーラー曲線（平衡飽和度 vs 液滴半径）の計算。
    - `1010hpa_60deg/`: 1010 hPa、60°Cでの計算。
        - `kohler.f90`: メインの計算コード。目標の過飽和度に一致するようにパラメータ`b`を探索します。
        - `plot.py`: ケーラー曲線を可視化するスクリプト。
    - `b_fixed_change_tc/`: パラメータ`b`を固定し、温度（Tc）を変化させた計算。
        - `kohler.f90`: メインの計算コード。
        - `plot.py`: 結果を可視化するスクリプト。

## 実行と可視化の方法

1.  **Fortranコードをコンパイルする:**
    ```bash
    gfortran diffusion_growth.f90  # または kohler.f90
    ```

2.  **実行ファイルを実行する:**
    ```bash
    ./a.out | tee output.log
    ```
    （注：一部のスクリプトは特定の `.dat` ファイルに直接出力しますが、標準出力に出力するものもあります）。

3.  **結果を可視化する:**
    ```bash
    python3 plot.py
    ```