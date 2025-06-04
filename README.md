# TGI SSH
text-generation-inference 的使用環境，可以省去下載套件的時間。

---

`git clone` 之後，建議在 `.git/info/exclude` 中加入以下內容：
```
docker-compose-ssh*.yml
!docker-compose-ssh.yml

docker-compose-service*.yml
!docker-compose-service.yml

Dockerfile*
!Dockerfile
```
因為 Server 裡面可能會因為各種不同人或不同的服務要用而有一堆 docker-compose-ssh-xxx.yml 和 docker-compose-service-xxx.yml，這樣可以讓本地的 git 忽略掉這些檔案，避免不必要的衝突。

## Build Image
```bash
cd TGI_ssh
docker build -t tgi_ssh:3.3.2 .
```
版本可自行進行替換

## Model Volume
預設放在 `./data` 資料夾  
會綁定到 container 中的 `/data`   
模型直接載進去就行  
```bash
cd /data  
huggingface-cli download meta-llama/Llama-3.2-1B --local-dir meta-llama/Llama-3.2-1B  
```
其他細節可以參考 [Hugging Face CLI](https://huggingface.co/docs/huggingface_hub/en/guides/cli)

## Docker Compose
使用 docker-compose 來啟動 TGI 服務，後續就可以透過 ssh 登入 container 了
```bash
cd TGI_ssh
docker-compose -f docker-compose-ssh.yml up -d
```
`docker-compose-ssh.yml` 中  
`port1:22` 是 ssh 的 port，  
`port2:80` 是服務的 port，  
PASSWORD 改成自己要的密碼

---

如果是 Ampere 的 GPU (30系、40系、A6000) 要指定顯卡 id 或數量
```yaml
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              device_ids:
                - "0"
                - "1"
```
如果是非 Ampere 的 GPU (Titan) 要指定 all 就行，而且 dtype 只能是 float16
```yaml
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
```


## SSH 登入
連接時輸入以下指令  
可登入 root  
密碼為先前設定的值
```bash
ssh -p ${port1} root@${ip}
```

## 開啟 TGI 服務
開啟服務方式參考 [TGI](https://huggingface.co/docs/text-generation-inference/basic_tutorials/using_cli)  
example : 
```bash
nohup text-generation-launcher --model-id /data/meta-llama/Llama-3.2-1B --trust-remote-code --dtype bfloat16 --max-input-length 8191 --max-total-tokens 8192 --max-batch-prefill-tokens 8192 > tgi.log 2>&1 &
```
將 `/data/meta-llama/Llama-3.2-1B` 換成自己的模型路徑  
`--dtype` 如果是非 Ampere 的 GPU (Titan) 必須指定 `float16`  
服務會開在 port2  
如果要關掉可透過 ps -ef 查看所有與 TGI 相關的 process  
然後透過 kill -9 ${pid} 關閉


## 使用 TGI 服務
```bash
curl 127.0.0.1:80/generate \
    -X POST \
    -d '{"inputs": "Hello, my name is", "parameters": {"max_new_tokens": 10}}' \
    -H 'Content-Type: application/json'
```
從外面連線就把 `127.0.0.1:80` 改成對外的 ip+port 即可


## Run TGI Service
直接開啟服務，沒有 ssh 登入  

---

`docker-compose-service.yml` 中  
model-id 可設定 huggingface 的 model-id 或直接用 local 模型  
如果是 Ampere 的 GPU (30系、40系、A6000) 要指定顯卡 id 或數量

```yaml
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              device_ids:
                - "0"
                - "1"
```
如果是非 Ampere 的 GPU (titan) 要指定 all 就行，而且 `dtype` 只能是 `float16`

```yaml
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
```
```bash
cd TGI_ssh
docker-compose -f docker-compose-service.yml up -d
```
