functor
import
   Input at 'Input.ozf'
   Browser(browse:Browse)
   Player at 'Player1.ozf'
   OS
   System
export
   portPlayer:StartPlayer
define
   StartPlayer
   TreatStream
   InitPosition
   Move
   Dive
   ChargeItem
   FireItem
   FireMine
   IsDead
   SayMove
   SaySurface
   SayCharge
   SayMinePlaced
   SayMissileExplode
   SayMineExplode
   SayPassingDrone
   SayAnswerDrone
   SayPassingSonar
   SayAnswerSonar
   SayDeath
   SayDamageTaken

   %fcts ajoutées
   IsIsland
   Histo
   IsValidPath
   Random
   RandomPosition
   FindInList
   RemoveFromList
in

   fun{IsIsland L X Y} %testé et approuvé
      local IsIsland2 in
	 fun{IsIsland2 M A}
	    if A==1 then M.1
	    else {IsIsland2 M.2 A-1}
	    end
	 end
	 {IsIsland2 {IsIsland2 L X} Y}
      end
   end

   fun{Histo L E} %testé et approuvé
      case L of nil then true
      [] H|T then
	 if H==E then false
	 else {Histo T E}
	 end
      end
   end

   fun{IsValidPath L E} %testé et approuvé
      local X Y in
	 pt(x:X y:Y)=E
	 (X >= 1 andthen X =< Input.nRow andthen Y >= 1 andthen Y =< Input.nColumn) andthen {IsIsland Input.map X Y} == 0 andthen {Histo L E}
      end
   end


   fun {Random N}
      {OS.rand} mod N + 1
   end

   %Je suppose qu'il n'existe aucune colonne avec que des 1
   fun{RandomPosition M}
      local X Y in
	 X={Random Input.nRow}
	 Y={Random Input.nColumn}
	 if {IsIsland M X Y}==0 then pt(x:X y:Y)
	 else {RandomPosition M}
	 end
      end
   end

   fun {FindInList L N}
      if N==1 then L.1
      else {FindInList L.2 N-1}
      end
   end

   fun{RemoveFromList L A}
      case L of nil then nil
      [] H|T then
	 if H==A then {RemoveFromList T A}
	 else H|{RemoveFromList T A}
	 end
      end
   end

   fun{Move ?Position State}
      local PotDirection Direction CandPos in
	 PotDirection=[east south west north surface]
	 Direction={FindInList PotDirection {Random 5}}
	 case Direction of east then CandPos=pt(x:State.pos.x y:State.pos.y+1)
	 [] south then CandPos=pt(x:State.pos.x+1 y:State.pos.y)
	 [] west then CandPos=pt(x:State.pos.x y:State.pos.y-1)
	 [] north then CandPos=pt(x:State.pos.x-1 y:State.pos.y)
	 [] surface then
	    Position=State.pos
	    {Record.adjoin State player(immersed:false path:Position|nil)}
	 end
	 if({IsValidPath State.path CandPos}==true) then
	    Position=CandPos
	    {Record.adjoin State player(pos:Position path:Position|State.path)}
	 end
      end
   end

   fun{ChargeItem ?KindItem State}
      case KindItem of mine then
	 if State.loadMine+1==Input.mine then
	    {Record.adjoin State player(loadMine:0 numberMine:State.numberMine+1)}
	 else
	     KindItem=null
	    {Record.adjoin State player(loadMine:State.loadMine+1)}
	 end
      [] missile then
	 if State.loadMissile+1==Input.missile then
	    {Record.adjoin State player(loadMissile:0 numberMissile:State.numberMissile+1)}
	 else
	    KindItem=null
	    {Record.adjoin State player(loadMissile:State.loadMissile+1)}
	 end
      [] drone then
	 if State.loadDrone+1==Input.drone then
	    {Record.adjoin State player(loadDrone:0 numberDrone:State.numberDrone+1)}
	 else
	    KindItem=null
	    {Record.adjoin State player(loadDrone:State.loadDrone+1)}
	 end
      [] sonar then
	 if State.loadSonar+1==Input.sonar then
	    {Record.adjoin State player(loadSonar:0 numberSonar:State.numberSonar+1)}
	 else
	    KindItem=null
	    {Record.adjoin State player(loadSonar:State.loadSonar+1)}
	 end
      end
   end

   fun{FireItem ?KindFire ListFire State}
      if ListFire==nil then
	 KindFire=null
	 skip
      end
      local Fire in
	 Fire={FindInList ListFire {Random {List.Length ListFire}}}
	 case Fire of mine then
	    if State.numberMine<1 then
	       {FireItem ?KindFire {RemoveFromList ListFire mine} State}
	    else
	       KindFire=mine({RandomPosition Input.map})
	       {Record.ajdoin State player(listMine:KindFire|State.listMine numberMine:State.numberMine-1)}
	    end
	 [] missile then
	    if State.numberMissile>0 then
	       KindFire=missile({RandomPosition Input.map})
	       {Record.ajdoin State player(listMissile:KindFire|State.listMissile numberMissile:State.numberMissile-1)}
	    else
	       {FireItem ?KindFire {RemoveFromList ListFire missile} State}
	    end
	 [] drone then
	    if State.numberDrone>0 then
	       KindFire=drone(row {Random Input.nrow})
	       {Record.ajdoin State player(numberDrone:State.numberDrone-1)}
	    else
	       {FireItem ?KindFire {RemoveFromList ListFire drone} State}
	    end
	 [] sonar then
	    if State.numberSonar>0 then
	       KindFire=sonar
	       {Record.ajdoin State player(numberSonar:State.numberSonar-1)}
	    else
	       {FireItem ?KindFire {RemoveFromList ListFire sonar} State}
	    end
	 end
      end
   end

   fun{FireMine ?Mine State}
      case State.listMine of nil then Mine=null
      [] H|T then
	 Mine=H
	 {Record.adjoin State player(listMine:{RemoveFromList State.listMine H})}
      end
   end

   fun{IsDead ?Answer}
      {Browse 1}
   end

   fun{SayMove ID Direction}
      {Browse 1}
   end

   fun{SaySurface ID}
      {Browse 1}
   end

   fun{SayCharge ID KindItem}
      {Browse 1}
   end

   fun{SayMinePlaced ID}
      {Browse 1}
   end

   fun{SayMissileExplode ID Position ?Message State}%simon

       if Position.y==State.pos.y andthen Position.x==State.pos.x then
          if (State.life < 3 )then
              Message=sayDeath(State.id)
              {Record.adjoin State player(life:0)}

          else
              Message=sayDamageTaken(State.id 2 State.life+2)
              {Record.adjoin State player(life:State.life-2)}
          end
      else
            if (({Number.abs Position.y-State.pos.y}+{Number.abs Position.x-State.pos.x})<2) then
                if State.life < 2 then
                     Message=sayDeath(State.id)
                    {Record.adjoin State player(life:0)}

                else
                    Message=sayDamageTaken(State.id 1 State.life+1)
                    {Record.adjoin State player(life:State.life-1)}

                end
            else
                State
            end
       end
   end

   fun{SayMineExplode ID Position ?Message State}%simon
       if Position.y==State.pos.y andthen Position.x==State.pos.x then
          if (State.life < 3 )then
              {Record.adjoin State player(life:0)}
              Message=sayDeath(State.id)
          else
              {Record.adjoin State player(life:State.life-2)}
              Message=sayDamageTaken(State.id 2 State.life+2)
          end
      else
            if (({Number.abs Position.y-State.pos.y}+{Number.abs Position.x-State.pos.x})<2) then
                if State.life < 2 then
                    {Record.adjoin State player(life:0)}
                    Message=sayDeath(State.id)
                else
                    {Record.adjoin State player(life:State.life-1)}
                    Message=sayDamageTaken(State.id 1 State.life+1)
                end
            else
                null
            end
       end
   end

   fun{SayPassingDrone Drone ?ID ?Answer}
      {Browse 1}
   end

   fun{SayAnswerDrone Drone ID Answer}
      {Browse 1}
   end

   fun{SayPassingSonar ?ID ?Answer}
      {Browse 1}
   end

   fun{SayAnswerSonar ID Answer}
      {Browse 1}
   end

   fun{SayDeath ID} %simon
      {System.show deeeeaaaattthhh}%
   end

   fun{SayDamageTaken ID Damage lifeLeft}
      {Browse 1}
   end

   fun{StartPlayer Color ID}
      Stream
      Port
      PlayerState
   in
      %immersed pour savoir si il est en surface ou pas
      PlayerState = player(id(id:ID color:Color name:'Player') path:nil pos:nil immersed:false life:Input.maxDamage listMine:nil loadMine:0 numberMine:0 listMissile:nil loadMissile:0 numberMissile:0 loadDrone:0 numberDrone:0 loadSonar:0 numberSonar:0)
      {NewPort Stream Port}
      thread
	 {TreatStream Stream PlayerState}
      end
      Port
   end

   proc {TreatStream Stream State}
      case Stream of nil then skip
      [] initPosition(?ID ?Position)|T then
	 ID=State.id
	 Position={RandomPosition Input.map}
	 local Newstate in
	    Newstate={Record.adjoin State player(path:Position|nil)}
	    {TreatStream T Newstate}
	 end
      [] move(?ID ?Position ?Direction)|T then
	 ID=State.id
	 local Newstate in
	    Newstate={{Move Position State} State}
	    {TreatStream T Newstate}
	 end
      [] dive|T then
	 local Newstate in
	    Newstate={Record.adjoin State player(immersed:true)}
	    {TreatStream T Newstate}
	 end
      [] chargeItem(?ID ?KindItem)|T then
	 ID=State.id
	 local Newstate in
	    Newstate={{ChargeItem ?KindItem State} State}
	    {TreatStream T Newstate}
	 end
      [] fireItem(?ID ?KindFire)|T then ID=State.id
	 local Newstate ListFire in
	    ListFire=[mine missile drone sonar]
	    Newstate={{FireItem ?KindFire ListFire State} State}
	    {TreatStream T Newstate}
	 end
      [] fireMine(?ID ?Mine)|T then
	 local Newstate in
	    Newstate={{FireMine ?Mine State} State}
	    {TreatStream T Newstate}
	 end
      [] isDead(?Answer)|T then {IsDead Answer 0}
	 {TreatStream T State}
      [] sayMove(ID Direction)|T then {SayMove ID Direction 0}
	 {TreatStream T State}
      [] saySurface(ID)|T then {SaySurface ID 0}
	 {TreatStream T State}
      [] sayCharge(ID KindItem)|T then {SayCharge ID KindItem 0}
	 {TreatStream T State}
      [] sayMinePlaced(ID)|T then {SayMinePlaced ID 0}
	 {TreatStream T State}
      [] sayMissileExplode(ID Position ?Message)|T then %simon
      local Newstate in
         Newstate={SayMissileExplode ID Position ?Message State}
      end
	 {TreatStream T State}
      [] sayMineExplode(ID Position ?Message)|T then %simon
      local Newstate in
          Newstate={{SayMineExplode ID Position ?Message State} State}
      end
   {TreatStream T State}
      [] sayPassingDrone(Drone ?ID ?Answer)|T then {SayPassingDrone Drone ID Answer 0}
	 {TreatStream T State}
      [] sayAnswerDrone(Drone ID Answer)|T then {SayAnswerDrone Drone ID Answer 0}
	 {TreatStream T State}
      [] sayPassingSonar(?ID ?Answer)|T then {SayPassingSonar ID Answer 0}
	 {TreatStream T State}
      [] sayAnswerSonar(ID Answer)|T then {SayAnswerSonar ID Answer 0}
	 {TreatStream T State}
      [] sayDeath(ID)|T then {SayDeath ID 0}
	 {TreatStream T State}
      [] sayDamageTaken(ID Damage lifeLeft)|T then {SayDamageTaken ID Damage lifeLeft 0}
	 {TreatStream T State}
      end
   end
end
