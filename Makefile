make:
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c input.oz
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c playerManager.oz
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c Player.oz
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c GUI.oz
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c main.oz

	/Applications/Mozart2.app/Contents/Resources/bin/ozengine  main.ozf

main:
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c main.oz
	/Applications/Mozart2.app/Contents/Resources/bin/ozengine  main.ozf

ia:
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c IA.oz
	/Applications/Mozart2.app/Contents/Resources/bin/ozengine  IA.ozf


test:
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c ish.oz
	/Applications/Mozart2.app/Contents/Resources/bin/ozengine  ish.ozf

gui:
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c GUI.oz
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c main.oz
	/Applications/Mozart2.app/Contents/Resources/bin/ozengine  main.ozf

player:
	/Applications/Mozart2.app/Contents/Resources/bin/ozc -c Player.oz

	/Applications/Mozart2.app/Contents/Resources/bin/ozengine  main.ozf


#To make the whole project working, first compile the Input.oz file, PlayerManager.oz file, players files,GUI.oz and Main.oz. Then execute the created functor file Main.ozf.
