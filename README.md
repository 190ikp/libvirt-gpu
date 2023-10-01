# `libvirt` + `vagrant` による仮想マシンへのGPUパススルー

- ホストのセットアップは[こちら](https://github.com/NVIDIA/deepops/blob/master/virtual/README.md#enabling-virtualization-and-gpu-passthrough)
- `vagrant-libvirt`については[こちら](https://github.com/vagrant-libvirt/vagrant-libvirt#pci-device-passthrough)

を参照

## 構築手順

### Vagrantのインストール

[`setup_host.sh`](setup_host.sh)の`setup_vagrant`を実行

### カーネルの設定変更

[`setup_host.sh`](setup_host.sh)の`setup_kernel`を実行

完了したらホストを再起動する

### 仮想マシンで使用するGPUをブラックリストに追加

使用するGPUがNVIDIA製の場合

1. `lspci -nn | grep -i nvidia`でGPUのPCI IDを表示

    以下のような表示が出てくる

    ```shell
    $ lspci -nn | grep -i nvidia
    3b:00.0 VGA compatible controller [0300]: NVIDIA Corporation GV102 [10de:1e07] (rev a1)
    3b:00.1 Audio device [0403]: NVIDIA Corporation Device [10de:10f7] (rev a1)
    3b:00.2 USB controller [0c03]: NVIDIA Corporation Device [10de:1ad6] (rev a1)
    3b:00.3 Serial bus controller [0c80]: NVIDIA Corporation Device [10de:1ad7] (rev a1)
    af:00.0 VGA compatible controller [0300]: NVIDIA Corporation GV102 [10de:1e07] (rev a1)
    af:00.1 Audio device [0403]: NVIDIA Corporation Device [10de:10f7] (rev a1)
    af:00.2 USB controller [0c03]: NVIDIA Corporation Device [10de:1ad6] (rev a1)
    af:00.3 Serial bus controller [0c80]: NVIDIA Corporation Device [10de:1ad7] (rev a1)
    ```
    この場合では`10de:1e07`，`10de:10f7`，`10de:1ad6`，`10de:1ad7`が使用するPCI ID

2. `/etc/modprobe.d/vfio.conf`にPCI IDを記載

    `options vfio-pci ids=<PCI IDのリスト>`を書き込む

    今回の場合は

    ```shell
    $ cat /etc/modprobe.d/vfio.conf
    options vfio-pci ids=10de:1e07,10de:10f7,10de:1ad6,10de:1ad7
    ```

3. `sudo update-initramfs -u`を実行する
4. ホストを再起動
5. `dmesg | grep -i vfio`を実行する．出力が得られればOK

NVIDIA GPUの場合，1-3までは[`setup_host.sh`](setup_host.sh)の`setup_vfio`を実行することで自動で行われる

### 仮想マシンの起動

1. [`Vagrantfile`](Vagrantfile)を修正する
  
    環境に合わせて`v.pci`の行を書き換える

    今回の場合で例えば`3b:00.0`のGPUを仮想マシンに割り当てるなら

    ```ruby
    v.pci :domain => '0x0000', :bus => '0x3b', :slot => '0x00', :function => '0x0'
    ```

    また，仮想マシンにはGPUのVGAデバイスだけではなく，AudioなどのGPUに付随しているすべてのデバイスを割り当てる必要がある

    今回の場合は

    ```ruby
    v.pci :domain => '0x0000', :bus => '0x3b', :slot => '0x00', :function => '0x0'
    v.pci :domain => '0x0000', :bus => '0x3b', :slot => '0x00', :function => '0x1'
    v.pci :domain => '0x0000', :bus => '0x3b', :slot => '0x00', :function => '0x2'
    v.pci :domain => '0x0000', :bus => '0x3b', :slot => '0x00', :function => '0x3'
    ```

    となる

    NVIDIA GPUの場合は[`setup_host.sh`](setup_host.sh)の`print_vgpu`を実行することでフォーマット済みの文字列を出力できる
2. `vagrant up`を実行
   
    `cuda-drivers`，`nvidia-container-toolkit`，`docker`がインストールされた状態の仮想マシンが立ち上がる

    仮想マシン内へは`vagrant ssh <仮想マシン名>`でアクセスできる

## 注意点

- 1つのGPUは1つの仮想マシンにのみ割り当てられる
- 仮想マシンに割り当てられたGPUは，仮想マシンの起動中にホスト上で使用できない
- 先にGPU関連のパッケージをアンインストールしておく必要がある(`cuda-drivers`，`nvidia-conatainer-toolkit`など)
  - でないと仮想マシンの起動時に`NVRM: Attempting to remove minor device 1 with non-zero usage count!`を吐いてフリーズする
