<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    <form action="index.php" method="POST">
        Name:<input type="text" name="name"><br>
        Link:<input type="text" name="link"><br>
        Player:<input type="text" name="player"><br>
        <button type="submit">Add</button>
    </form>
</body>
</html>

<?php
    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        $name = str_replace("/","_",$_POST["name"]);
        $pos = strpos($_POST["link"],"&");
        if ($pos) {
            $link = substr($_POST["link"],0,$pos);
        } else {
            $link = $_POST["link"];
        }
        $player = $_POST["player"];

        $command = ('python3 LOCALaddSong.py '.$name.' '.$link.' '.$player);
	//$command = ('./yt-dlp_linux -o ./download/'.$name.'.webm '.$link);
	echo $command;
	echo "<br>";
        $output = shell_exec($command);
        echo $output;
	copy("converted/".$name.".dfpwm","users/".$player."/".$name.".dfpwm");
	unlink("download/".$name.".webm");
	unlink("converted/".$name.".dfpwm");
    }
?>
