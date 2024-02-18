<?php

$users = scandir("./users");
foreach ($users as $user) {
   if ($user != "." && $user != "..") {
      $songs = scandir("./users/".$user);
      foreach ($songs as $song) {
         if ($song != "." && $song != "..") {
            echo substr_replace($user."/".$song,"",-6)."<br>";
         }
      }
   }
}