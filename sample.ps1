param($params = @{})

$x= @"
<!doctype html>
<html>
<head>
<title>Test POST</title>
<head>
<body>
  <h1>Test POST</h1>
  <h2>Can you believe it?</h2>
  <ul>
"@ +(
    (
      $params.keys | %{
        "<li> $_ => "+ $params[$_] +"</li>"
      }
    ) -join ''
  )+ @"
  </ul>
</body>
</html>
"@

return $x
