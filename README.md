# flavor_setup
# HOW TO USE
1. Place the file directly inside lib folder of your flutter app
2. Right now only 2 modes(prod and dev are supported), hit run and it should create(if not already created) the folder core for you
3. Inside the core folder, you will have your const folder and your flavor folder
4. You will have 2 flavor files in it, dev.dart and prod.dart, both will contain the relevant code for running flavor in your flutter app
5. your main.dart file's void main() function would have been changed to mainCommon()
6. Inside your build gradle you will notice above the buildTypes, flavorDimension and flavor have been specified
7. Next to use them, add the dev.dart and prod.dart as an entry point inside android studio's run's edit configuration
8. Also mention 'dev' and 'prod' inside flavor arguments while editing configuration
9. Eventual support for more flavors as well as further configuration to flavor_config file will get added as well
