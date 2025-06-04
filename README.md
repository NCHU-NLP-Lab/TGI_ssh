# TGI_ssh
text-generation-inference 的使用環境，
可以省去下載套件的時間

## build image
版本可自行進行替換
```bash
cd TGI_ssh
docker build -t tgi_ssh:3.3.2 .
```

## model volume
預設放在 `./data` 資料夾  
會綁定到 container 中的 `/data`   
模型直接丟進去就行  

## run ssh TGI
```bash
cd TGI_ssh
docker-compose -f docker-compose-ssh.yml up -d
```
docker-compose-ssh.yml 中  
`port1:22` 是 ssh 的 port，  
`port2:80` 是服務的 port，  
PASSWORD 改成自己要的密碼，

如果是 Ampere 的 GPU (30系、40系、A6000) 要指定顯卡 id 或數量
```shell=
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              device_ids:
                - "0"
                - "1"
```
如果是非 Ampere 的 GPU (titan) 要指定 all 就行，而且 dtype 只能是 float16
```shell=
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
```

連接時輸入以下指令  
可登入 root  
密碼為先前設定的值
```shell=
$ ssh -p ${port1} root@${ip}
```

開啟服務方式參考 [TGI](https://huggingface.co/docs/text-generation-inference/basic_tutorials/using_cli)  
example : 
```bash
nohup text-generation-launcher --model-id /data/meta-llama/Llama-3.2-1B --trust-remote-code --dtype bfloat16 --max-input-length 8191 --max-total-tokens 8192 --max-batch-prefill-tokens 8192 > tgi.log 2>&1 &
```
服務會開在 port2  
如果要關掉可透過 ps -ef 查看所有與 TGI 相關的進程  
然後透過 kill -9 ${pid} 關閉


## 使用範例

```shell=
$ curl 127.0.0.1:80/generate \
    -X POST \
    -d '{"inputs": "Hello, my name is", "parameters": {"max_new_tokens": 10}}' \
    -H 'Content-Type: application/json'
```
把 `127.0.0.1:80` 換成對外的 ip+port 即可


## run TGI service
直接開啟服務，沒有 ssh 登入  

docker-compose-service.yml 中  
model-id 可設定 huggingface 的 model-id 或直接用 local 模型  
如果是 Ampere 的 GPU (30系、40系、A6000) 要指定顯卡 id 或數量
```shell=
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              device_ids:
                - "0"
                - "1"
```
如果是非 Ampere 的 GPU (titan) 要指定 all 就行，而且 dtype 只能是 float16
```shell=
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
```
```shell=
$ cd TGI_ssh
$ docker-compose -f docker-compose-service.yml up -d
```
