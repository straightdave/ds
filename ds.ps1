##
## dave's server (ds)
## Dave Wu, 2014
##

param(
[int]$port = 8889,
[int]$max_connection = 50
)

try{
  $server = [system.net.sockets.tcplistener]$port
} catch [Exception] {
  write-host "cannot open port" $port
  exit
}

# load function lib
$execPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
. $execPath\ds_lib.ps1

$server.start($max_connection)
write-host "server started on" $port

while( $true ){
  $client = $server.AcceptTcpClient()
  write-host "got a request"
  
  $resp_msg = ""
  $stream = $client.GetStream()

  if($stream.canread){
    write-host "[Read Request]================================="
    $avail = $client.available
    write-host $avail "bytes available"
    
    $bytes = new-object system.byte[] $avail
    $stream.read($bytes, 0, $bytes.length)
    
    $req_msg = [system.text.encoding]::utf8.getstring($bytes)
    write-host "host returned:" $req_msg.length "bytes"
            
    $resp_msg = GenerateMessage($req_msg)
  }
  else{
    write-host "cannot read data"
    $client.close()
    $stream.close()
    continue
  }

  if($stream.canwrite -and $resp_msg -ne ""){
    write-host "[Send Response]========================"
    $msg = [system.text.encoding]::utf8.getbytes($resp_msg)
    $stream.write($msg, 0, $msg.length)
  }
  
  $client.close()
  write-host "A request done."
  $stream.close()
}

$server.Stop()
write-host "server stopped."
exit
