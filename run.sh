#!/bin/bash
BOOTDIR="./bootnode.txt"
OUTPUTLOG="./cypherlog.txt"
LOGLEVEL=3

IPENCDISVALUE=1
CONSOLEMODE="--console"
BACKENDMODE="--backend"
CLIMODE=$CLISILENTMODE

ostype()
{
  osname=`uname -s`
 # echo "osname $osname"
  OSTYPE=UNKNOWN
  case $osname in
     "FreeBSD") OSTYPE="freebsd"
     ;;
     "SunOS") OSTYPE="solaris"
     ;;
     "Linux") OSTYPE="linux"
     ;;
     "Darwin") OSTYPE="darwin"
     ;;
     "linux") OSTYPE="linux"
     ;;
     "darwin") OSTYPE="darwin"
     ;;
     *) echo "other system $osname"
     ;;
    esac
  return 0

}

if [[ "$1" != "" ]];then
   CLIMODE=$1
fi
ostype
CHAINDB="./database/chaindb"
BINDIR="./database/$OSTYPE/cypher"
RNET_PORT=7100
P2P_PORT=6000
RPC_PORT=8000
select=$2
GENESIS_FILE="genesis.json"
if [[ "$select" == "test" ]];then
        BINDIR="./database/$OSTYPE/cyphertest"
        CHAINDB="./database/chaindbtest"
        OUTPUTLOG="cypherlogtest.txt"
        GENESIS_FILE="genesistest.json"
        BOOTDIR="./bootnodetest.txt"
fi

echo "CHAINDB $CHAINDB"
echo "BINDIR $BINDIR"
killall -9 cypher
killall -9 cyphertest
NetWorkId=`less $GENESIS_FILE|awk -F "[:]" '/chainId/{print $2}'`
NetWorkId=`echo $NetWorkId | cut -d \, -f 1`
ip=`curl icanhazip.com`
echo "ip: $ip"
bootnode_addr=enode://"$(grep enode $BOOTDIR|tail -n 1|awk -F '://' '{print $2}')"
echo "bootnode address: $bootnode_addr"
echo "Client print mode:$CLIMODE,please wait for some seconds!"
if [[ "$CLIMODE" == "$CLISILENTMODE" || "$CLIMODE" == "0" || "$CLIMODE" == " " ]];then
   nohup $BINDIR --nat=extip:$ip  --syncmode full --allow-insecure-unlock --http.corsdomain "*" --http.addr 0.0.0.0 --rpc.gascap 0 --rpc.txfeecap 1000 --http --http.api eth,web3,net,personal,miner,txpool --rnetport $RNET_PORT --port $P2P_PORT --http.port $RPC_PORT --verbosity $LOGLEVEL  --datadir $CHAINDB --networkid $NetWorkId  --bootnodes "$bootnode_addr"    > "$OUTPUTLOG" 2>&1 &
else
         $BINDIR --nat "none" --datadir $CHAINDB --verbosity 3 --syncmode full --allow-insecure-unlock --http.corsdomain "*" --http.addr 0.0.0.0 --rpc.gascap 0 --rpc.txfeecap 1000 --http --http.api eth,web3,net,personal,txpool --http.port $RPC_PORT --bootnodes "enode://a294a4d23b3c0671eac267ae0df03487e79ae58f52b668514e3510a292a13853dd3070deb6f703fe2c92a68609fcfd603cd6e7cf6ddb418fa523612285219293@218.185.241.185:30301" --metrics --networkid 16166 console
         #$BINDIR --verbosity "$LOGLEVEL" --rnetport 7100 --syncmode full  --nat=extip:$ip --allow-insecure-unlock --ws --ws.addr="0.0.0.0" --ws.port 8546  --ws.origins "*" --http.corsdomain "*" --http.addr 0.0.0.0 --http --http.api eth,web3,net,personal,miner,txpool --port 6000 --http.port 8000 --targetgaslimit "3758096384" --datadir $CHAINDB --networkid $NetWorkId --gcmode archive --datadir $CHAINDB --bootnodes "$bootnode_addr"  console
fi
