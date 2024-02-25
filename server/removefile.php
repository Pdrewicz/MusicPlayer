<?php

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $name = $_POST["name"];
    $player = $_POST["player"];
    unlink("users/".$_POST["player"]."/".$_POST["name"]);
}
