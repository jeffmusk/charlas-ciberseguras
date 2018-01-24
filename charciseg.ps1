#INIT

$youtube_url = $args[0]

if($args[0] -eq $null ){
	write-host "Youtube Link: " -foreground green
	$youtube_url = read-host
}

if($youtube_url -notmatch 'https://www.youtube.com/watch...\w+' ){
	write-error -Message "Error URL invalida" -Category InvalidArgument
	exit
}

if((test-path "README.md") -eq $false -or (test-path "urls.txt") -eq $false){
	write-error -Message "ERROR Archivo README.md o urls.txt faltantes"
	exit
}

$url_list = get-content urls.txt
$repeated=$false
   foreach ($url in $url_list){
	if($youtube_url -eq $url){
		$repeated=$true
	    break
	}
   }if($repeated){
   		write-warning "El link $youtube_url ya se encuentra en la lista"
   		exit
   }

#END_INIT

#--

write-host "Extrayendo info" -foreground green
$yt_handler = invoke-webrequest $youtube_url

$list = get-content README.md -Encoding String

$i=0
   
   if($yt_handler.content -match '<title>.+(?= - YouTube</title>)'){}#silent
   $title = $matches[0].substring(7)
   if($title -match '\|'){$title -replace '\|',""}
   
   if($yt_handler.content -match '"name": "[\w ]+'){}#silent
   $author = $matches[0].substring(9)

   if($yt_handler.content -match '\d{4}-\d{2}-\d{2}'){}#silent
   $date = $matches[0]

    foreach($line in $list){
	if($line -match '\d{4}-\d{2}-\d{2}'){
	    $date2=$matches[0] -replace "-",""
	    $date2 = $date2.ToInt32($null)
	    $date_temp = $date -replace "-",""
	    if($date_temp.ToInt32($null) -gt $date2){break}
	}
        $i++
    }

$list[5] = "**Ultima charla agregada: ["+$title+"]("+$youtube_url+")**`n"

$list[$i-1] += "`n" + "| [" + $title + "](" + $youtube_url + ") | " + $author + " | " + $date + " | "
$list | set-content README.md -Encoding String
add-content urls.txt $youtube_url -Encoding String
$i=$i-10

write-host "'$title' `n de: $author `n fecha: $date `n `n agregado a la posicion $i de la tabla :)" -foreground green
