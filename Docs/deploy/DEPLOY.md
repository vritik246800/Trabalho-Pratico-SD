# Deploy AgroGest — Tomcat 10.1 + systemd

## Pré-requisitos

- Java 17+
- Apache Tomcat 10.1 instalado em `/opt/tomcat`
- Utilizador de sistema `tomcat`

## 1. Compilar o WAR

```bash
cd AgroGest
mvn package
# gera: target/agrogest.war
```

## 2. Configurar Tomcat na porta 8081

Editar `/opt/tomcat/conf/server.xml`:

```xml
<Connector port="8081" protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443" />
```

## 3. Fazer deploy do WAR

```bash
cp AgroGest/target/agrogest.war /opt/tomcat/webapps/
```

## 4. Instalar o serviço systemd

```bash
sudo cp Docs/deploy/agrogest.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable agrogest
sudo systemctl start agrogest
```

## 5. Verificar

```bash
sudo systemctl status agrogest
# Abrir: http://localhost:8081/agrogest/
```

## Persistência na paragem

O `AppListener.contextDestroyed` grava automaticamente o ficheiro `.ser`
quando o Tomcat para (`systemctl stop agrogest`). Os dados ficam em:

```
/opt/tomcat/data/agrogest.ser
```

## Comandos úteis

```bash
sudo systemctl start agrogest     # ligar
sudo systemctl stop agrogest      # parar (grava .ser)
sudo systemctl restart agrogest   # reiniciar
sudo journalctl -u agrogest -f    # ver logs em tempo real
```
