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

$CR = [char]13
$LF = [char]10
$CRLF = [char]13 + [char]10
$SP = [char]32

# return hash
function ParseReqMsg{
  param( [string]$req_msg )
  
  $req = @{}
  
  $lines = $req_msg.split($LF)  
  $splitter = (0..($lines.length-1)) | %{ if($lines[$_] -eq $CR){ return $_ } }
  
  $head = $lines[0..($splitter-1)]
  $body = $lines[($splitter+1)..($lines.length-1)] -join ''
    
  $req_line = $head[0]
  $req.add("Method",$req_line.trim().split($SP)[0])
  $req.add("Req-URI",$req_line.trim().split($SP)[1])
  $req.add("HTTP-Version",$req_line.trim().split($SP)[2])
  
  $head[1..($head.length-1)] | %{
    $first_colon = $_.indexof(':')
    $req.add($_.substring(0,$first_colon), $_.substring($first_colon + 1).trim())
  }
  
  $req.add("Body",$body)
  $req
}

function ValidateReqHash{
  param($req_hash = @{})  
  if($req_hash["Req-URI"]) {return $true}
  
  return $false
}

function GenerateMessage{
  param( [string]$req_msg )
  
  if(-not $req_msg) { write-host "request is blank" -fore yellow; return }
  
  $req = ParseReqMsg $req_msg
  $req >> $DSHOME\debug.txt
  #if(-not (ValidateReqHash $req)){ write-host "invalid req hash" -fore red; return }  
  
  # add body as params (post)
  if($req["Body"]){
    $req["Body"].split('&') | %{
      $global:DSPARAMS[($_.split('=')[0])] = $_.split('=')[1]
    }
  }
  
  # add params from uri (get)
  $get_p = Get-Param $req["Req-URI"]
  if($get_p){
    $get_p.split('&') | %{
      $global:DSPARAMS[($_.split('=')[0])] = $_.split('=')[1]
    }
  }
  
  #return ""
  
  #######################################
  write-host "method=" $req["Method"]
  write-host "req-uri=" $req["Req-URI"]
     
  # 'GET /', redirect to default
  if($req["method"] -eq "GET" -and $req["req-uri"] -eq "/") {
    $resp = "HTTP/1.1 301 Moved Permanently" + $CRLF
    $resp += "Location: /default.html" + $CRLF + $CRLF
    return $resp,0
  }
  
  $file = Get-FilePath($req["req-uri"])
  
  # 404
  if(-not (Test-Path (join-path $DSHOME $file))){
    write-host "cannot find" (join-path $DSHOME $file) -fore red
    
    $resp = "HTTP/1.1 404 Not Found" + $CRLF
    $resp += "Content-Type: text/html; charset=utf-8" + $CRLF
    
    if(Test-Path (join-path $DSHOME '404.html')){      
      $resp += $CRLF
      $content = gc (join-path $DSHOME '404.html')
      $resp += $content      
    }
    else{
      $resp += $CRLF
      $resp += $notfoundpage
    }
    return $resp
  }
  
  # 200 OK
  write-host "200 OK" (join-path $DSHOME $file) -fore green
  
  $resp = "HTTP/1.1 200 OK" + $CRLF
  $resp += "Content-Type: text/html; charset=utf-8" + $CRLF
  
  if($file.endswith(".ps1")){    
    $content = ParsePS1File (join-path $DSHOME $file)
    $resp += $CRLF
    $resp += $content
  }
  elseif($file.endswith(".ps2")){    
    $content = ParsePS2File (join-path $DSHOME $file)
    $resp += $CRLF
    $resp += $content
  }
  else{
    $content = gc (join-path $DSHOME $file) # plain text-based file: html, js...
    $resp += $CRLF
    $resp += $content
  }  
  return $resp
}

function Get-FilePath{
  param( [string]$uri )  
  # input uri should be like '/abc/abc/abc.xxx'  
  $uri.split('?')[0].replace('/','\')
}

# get Get params
function Get-Param{
  param( [string]$uri )  
  $uri.split('?')[1]
}

function ParsePS1File{
  param([string]$file)  
  $a = & $file $global:DSPARAMS
  return $a  
}

function ParsePS2File{
  param([string]$file)

  $content = [io.file]::readalltext($file)
  $allmatch_equ = $content | select-string '(?ims)<\$[=](.*?)\$>' -allmatches | %{$_.matches} | %{$_.value}
  $allmatch_noneequ = $content | select-string '(?ims)<\$[^=](.*?)\$>' -allmatches | %{$_.matches} | %{$_.value}

  $comms = 
  ($allmatch_noneequ | %{
    $_.trimstart("<$").trimend("$>").trim()
  }) -join ';'
  invoke-expression $comms

  $kvs = @{}
  $allmatch_equ | %{
    $c = $_.trimstart("<$=").trimend("$>").trim()    
    $value = invoke-expression $c    
    if($value -and $value.gettype().basetype.name -eq 'array'){
      $kvs[$_] = ($value -join '')  
    }else{
      $kvs[$_] = $value
    }
  }

  $page = $content -replace '(?ims)<\$[^=](.*?)\$>', ''
  $kvs.keys | %{ $page = $page.replace( $_, $kvs[$_]) }
  $page
}
