<?php

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $name = $_POST["name"];
    $player = $_POST["player"];

    $command = ("python3 ./LOCALremoveFile.py ".$_POST["player"]." ".$_POST["name"]);
    $output = shell_exec($command);
}
