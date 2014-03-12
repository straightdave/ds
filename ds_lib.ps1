##
## func lib for ds.ps1
## Dave Wu, 2014
##

$notfoundpage = @"
<html>
<head><title>404 Not Found</title></head>
<body><h1>404 Not Found</h1><hr><p>dave's server</p></body>
</html>
"@

function GenerateMessage{
  param(
  [string]$req_msg
  )
  
  if($req_msg -eq "" -or $req_msg -eq $null) {
    write-host "request is blank" -fore yellow
    return ""
  }
  
  $first_line = $req_msg.split([char]13)[0]
  write-host "first line" $first_line -fore yellow
  
  $method = $first_line.split([char]32)[0]
  $uri = $first_line.split([char]32)[1]
  $protocol = $first_line.split([char]32)[2]
  write-host "method:" $method
  write-host "uri:" $uri
  write-host "protocol:" $protocol
  
  #return ""
  
  $homedir = "C:\dshome"
  $crlf = [char]13 + [char]10
  
  $resp = ""
  
  if($uri -eq "/") {
    # redirect to /default.html
    write-host "redirect to default page" -fore yellow

    $resp = "HTTP/1.1 301 Moved Permanently" + $crlf
    $resp += "Server: dave's server/0.0.1" + $crlf
    $resp += "Location: /default.html" + $crlf + $crlf

    $resp += "Redirecting..." + $crlf + $crlf

    return $resp
  }
  
  $file = Get-FilePath($uri)
  
  if(-not (Test-Path (join-path $homedir $file))){
    # 404
    write-host "cannot find" (join-path $homedir $file) -fore red
    
    $resp = "HTTP/1.1 404 Not Found" + $crlf
    $resp += "Server: dave's server/0.0.1" + $crlf
    $resp += "Status: 404 Not Found" + $crlf
    $resp += "Connection: Keep Alive" + $crlf
    $resp += "Content-Type: text/html; charset=utf-8" + $crlf + $crlf
    
    if(Test-Path (join-path $homedir '404.html')){
      $resp += gc (join-path $homedir '404.html')
    }
    else{
      $resp += $notfoundpage
    }
    
    return $resp
  }
  
  # 200 OK
  write-host "200 OK" (join-path $homedir $file) -fore green
  
  $resp = "HTTP/1.1 200 OK" + $crlf
  $resp += "Server: dave's server/0.0.1" + $crlf
  $resp += "Status: 200 OK" + $crlf
  $resp += "Connection: Keep Alive" + $crlf
  $resp += "Content-Type: text/html; charset=utf-8" + $crlf + $crlf
  
  if($file.endswith(".ps1")){
    $resp += ParsePS2File (join-path $homedir $file) (Get-Param($uri))
  }
  else{
    $resp += gc (join-path $homedir $file) # plain text file: html, js...
  }
  
  return $resp
}

function Get-FilePath{
  param([string]$uri)
  
  # input uri should be like '/abc/abc/abc.xxx'  
  return $uri.split('?')[0].replace('/','\')
}

function Get-Param{
  param([string]$uri)
  
  return $uri.split('?')[1]
}

function ParsePS2File{
  param(
  [string]$file,
  [string]$params
  )
  
  # get all GET parameters into dict
  $getparams = @{}
  if($params -ne ""){
    $params.split('&') | %{
      $pair = $_.split('=')
      $getparams.add($pair[0],$pair[1])
    }
  }
  
  $a = & $file $getparams
  
  return $a  
}
