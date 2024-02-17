<?php

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $command = ("python3 ./LOCALcreateFolder.py ".$_POST["player"]);
    $output = shell_exec($command);
    echo $output;
}
