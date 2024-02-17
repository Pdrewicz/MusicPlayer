<?php

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $name = $_POST["name"];
    $exists = "false";
    if (file_exists("converted/".$name.".dfpwm")) {
        $exists = "true";
    }
    echo $exists;
}
