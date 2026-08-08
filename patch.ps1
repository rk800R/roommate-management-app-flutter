$content = Get-Content "lib/screens/HomeScreen.dart" -Raw
$old = 'onTap: () => _comingSoon(actions[i].$5),'
$new = @"
onTap: () {
  if (actions[i].$5 == 'New chores') {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChoreBoardScreen()));
  } else {
    _comingSoon(actions[i].$5);
  }
},
"@
$content = $content.Replace($old, $new)
Set-Content "lib/screens/HomeScreen.dart" $content
