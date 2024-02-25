<?php

if ($_SERVER["REQUEST_METHOD"] == "GET") {
    //$command = ("python3 LOCALlistFiles.py ".$_GET["player"]);
    //echo $command."<br>";
    //$output = shell_exec($command);
    //echo $output."<br>";
    $songs = scandir("users/".$_GET["player"]);
    $json= json_decode(file_get_contents("LOCALusers.json"),true);
    foreach ($json["users"] as $user) {
        if ($user["name"] == $_GET["player"]) {
            $user["songs"] = $songs;
            foreach ($user["songs"] as $song) {
                $pos = strpos($song,".dfpwm");
                if ($pos) {
                    echo substr($song,0,$pos);
                    echo "<br>";
                }
            }
        }
    }
    file_put_contents("LOCALusers.json",json_encode($json));
} elseif ($_SERVER["REQUEST_METHOD"] == "POST") {
    $songs = scandir("users/".$_POST["player"]);
    $command = ("python3 LOCALlistFiles.py ".$_POST["player"]);
    $output = shell_exec($command);
    $json= json_decode(file_get_contents("LOCALusers.json"),true);
    foreach ($json["users"] as $user) {
        if ($user["name"] == $_POST["player"]) {
            $user["songs"] = $songs;
            foreach ($user["songs"] as $song) {
                $pos = strpos($song,".dfpwm");
                if ($pos) {
                    echo substr($song,0,$pos);
                    echo "<br>";
                }
            }
        }
    }
    file_put_contents("LOCALusers.json",json_encode($json));
}
