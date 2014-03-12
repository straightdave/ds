param($GET = @{})

$title = $GET['mytitle']
$myh1 = $GET['myh1']

$x= @"
<!doctype html>
<html>
<head>
<title>$title</title>
<head>
<body>
  <h1>$myh1</h1>
  <h2>Can you believe it?</h2>
  <ul>
"@ +(
    (
      (1..10) | %{
        "<li>$_</li>"
      }
    ) -join ''
  )+ @"
  </ul>
</body>
</html>
"@

return $x
