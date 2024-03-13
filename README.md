# TGI_ssh
text-generation-inference的使用環境，
可以省去下載套件的時間
## build image
版本可自行進行替換
```shell=
$ cd TGI_ssh
$ docker build -t tgi_ssh:1.4 .
```
## model volume
預設放在./data資料夾
模型直接丟進去就行

## run ssh TGI
```shell=
$ cd TGI_ssh
$ docker-compose -f docker-compose-ssh.yml up -d
```
"port1:22"是ssh的port，  
"port2:80"是服務的port，  
PASSWORD改成自己要的密碼，

如果是Ampere的GPU(30系、40系、A6000)要指定顯卡數量，count: 2(取決於顯卡數量)
如果是非Ampere的GPU(titan)指定all就行，count: all

連接時輸入以下指令
```shell=
$ ssh -p ${port1} root@${ip}
```

開啟服務方式參考 [TGI](https://huggingface.co/docs/text-generation-inference/basic_tutorials/using_cli)  
example : 
```shell=
$ nohup text-generation-launcher --model-id /data/MediaTek-Research/Breeze-7B-Instruct-v0_1 --trust-remote-code --dtype float16 --max-input-length 16383 --max-total-tokens 16384 --max-batch-prefill-tokens 16384&
```
服務會開在port2

## run TGI service
直接開啟服務
model-id可設定huggingface的model-id或直接用local模型
如果是Ampere的GPU(30系、40系、A6000)要指定顯卡數量，count: 2(取決於顯卡數量)
如果是非Ampere的GPU(titan)指定all就行，count: all
```shell=
$ cd TGI_ssh
$ docker-compose -f docker-compose-service.yml up -d
```
