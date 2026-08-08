$content = Get-Content "lib/screens/HomeScreen.dart" -Raw
$old = [System.Text.RegularExpressions.Regex]::Escape("onTap: () {") + "`n  if (actions[i]. == 'New chores') {`n    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChoreBoardScreen()));`n  } else {`n    _comingSoon(actions[i].);`n  }`n},"
$new = "onTap: () {`n  if (actions[i].`$5 == 'New chores') {`n    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChoreBoardScreen()));`n  } else {`n    _comingSoon(actions[i].`$5);`n  }`n},"
$content = [regex]::Replace($content, [regex]::Escape("onTap: () {`n  if (actions[i]. == 'New chores') {`n    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChoreBoardScreen()));`n  } else {`n    _comingSoon(actions[i].);`n  }`n},"), $new)
Set-Content "lib/screens/HomeScreen.dart" $content
