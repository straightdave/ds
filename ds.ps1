##
## dave's server (ds)
## Dave Wu, 2014
##

param(
[int]$port = 8889
)

$global:DSHOME = "C:\dshome"
$global:DSPORT = $port
#$global:DSSESSION = @{}
$global:DSPARAMS = @{}

try{
  $server = [system.net.sockets.tcplistener]$port
} catch {
  write-host "cannot open port" $port
  exit
}

$execPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
. $execPath\ds_lib.ps1

$server.start()
write-host "server started at port" $port

while( $true ){  
  $client = $server.AcceptTcpClient()
  write-host "Got a request"
  
  $global:DSPARAMS = @{} # clear params per one connection
  
  $stream = $client.GetStream()

  if($stream.canread){
    write-host "[Read Request] " -nonewline
    $avail = $client.available
    write-host $avail "bytes available"
    
    $bytes = new-object system.byte[] $avail
    $stream.read($bytes, 0, $bytes.length)    
    $req_msg = [system.text.encoding]::utf8.getstring($bytes)
            
    $resp_msg = GenerateMessage $req_msg
    
    if($stream.canwrite -and $resp_msg){
      write-host "[Send Response]"
      $msg = [system.text.encoding]::utf8.getbytes($resp_msg)
      $stream.write($msg, 0, $msg.length)
    }
  }
  
  $client.close()
  $stream.close()
  write-host "A request done."
}

$server.Stop()
write-host "Server listening loop stopped."
exit
