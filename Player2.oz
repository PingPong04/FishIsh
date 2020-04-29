functor
import
   Input at 'Input.ozf'
   Player at 'Player2.ozf'
   OS
export
   portPlayer:StartPlayer
define
   StartPlayer
   TreatStream
   Move
   ChargeItem
   FireItem
   FireMine
   SayMissileExplode
   SayMineExplode
   SayPassingDrone
   SayPassingSonar

   %Added functions
   IsIsland
   Histo
   IsValidPath
   Random
   RandomPosition
   FindInList
   RemoveFromList
   GetNewPos
   Where
   ValidItem
in
   /*
    * IsIsland is use to know what is at pt(x:X y:Y) on the Input.map (equal to L)
    */
   fun{IsIsland L X Y}
      local IsIsland2 in
	 fun{IsIsland2 M A}
	    if A==1 then M.1
	    else {IsIsland2 M.2 A-1}
	    end
	 end
	 {IsIsland2 {IsIsland2 L X} Y}
      end
   end

   /*
    * Histo check if E is not in L (to know if we have already been at the position E in the State.path (L))
    */
   fun{Histo L E}
      case L of nil then true
      [] H|T then
	 if H==E then false
	 else {Histo T E}
	 end
      end
   end

   /*
    * IsValidPath respond true if the position E is within the limits of the map, in the water and is not in the State.path (E)
    */
   fun{IsValidPath L E}
      local X Y in
	 pt(x:X y:Y)=E
	 (X >= 1 andthen X =< Input.nRow andthen Y >= 1 andthen Y =< Input.nColumn) andthen {IsIsland Input.map X Y} == 0 andthen {Histo L E}
      end
   end

   /*
    * Return a random number between 1 and N
    */
   fun {Random N}
      {OS.rand} mod N + 1
   end

   /*
    * Return a random position in the water
    */
   fun{RandomPosition M}
      local X Y in
	 X={Random Input.nRow}
	 Y={Random Input.nColumn}
	 if {IsIsland M X Y}==0 then pt(x:X y:Y)
	 else {RandomPosition M}
	 end
      end
   end

   /*
    * Return the Nth élément in the list L
    */
   fun {FindInList L N}
      if N==1 then L.1
      else {FindInList L.2 N-1}
      end
   end

   /*
    * Remove A from the list L
    */
   fun{RemoveFromList L A}
      case L of nil then nil
      [] H|T then
	 if H==A then {RemoveFromList T A}
	 else H|{RemoveFromList T A}
	 end
      end
   end

   /*
    * choose a random Direction in the list L and check if the Direction is valid
    * return the Position and Direction found
    */
   fun {GetNewPos State L}
      if L==nil then nil
      else
	 local CandPos CandDir PosDir in
	    CandDir={FindInList L {Random {List.length L}}} % pick at random a path
	    case CandDir of east then CandPos=pt(x:State.pos.x y:State.pos.y+1)
	    [] south then CandPos=pt(x:State.pos.x+1 y:State.pos.y)
	    [] west then CandPos=pt(x:State.pos.x y:State.pos.y-1)
	    [] north then CandPos=pt(x:State.pos.x-1 y:State.pos.y)
	    end
            %check if pos is valid
	    if ({IsValidPath State.path CandPos}==true) then
	       PosDir=CandPos|CandDir
	    else
	       {GetNewPos State {RemoveFromList L CandDir}}
	    end
	 end
      end
   end

   /*
    * Handle that the player identified has made a missile explode at the given position.
    */
   fun{SayMissileExplode ID Position ?Message State}
      if Position.y==State.pos.y andthen Position.x==State.pos.x then
	 if (State.life < 3 )then
	    Message=sayDeath(State.id)
	    {Record.adjoin State player(life:State.life-State.life)}
	 else
	    Message=sayDamageTaken(State.id 2 State.life-2)
	    {Record.adjoin State player(life:State.life-2)}
	 end
      else
	 if (({Number.abs Position.y-State.pos.y}+{Number.abs Position.x-State.pos.x})<2) then
	    if State.life < 2 then
	       Message=sayDeath(State.id)
	       {Record.adjoin State player(life:State.life-State.life)}
	    else
	       Message=sayDamageTaken(State.id 1 State.life-1)
	       {Record.adjoin State player(life:State.life-1)}
	    end
	 else
	    Message=sayDamageTaken(State.id 0 State.life)
	    State
	 end
      end
   end

   /*
    * Handle that the player identified has made a mine explode at the given position.
    */
   fun{SayMineExplode ID Position ?Message State}%simon
      if Position.y==State.pos.y andthen Position.x==State.pos.x then
	 if (State.life < 3 )then
	    {Record.adjoin State player(life:State.life-State.life)}
	    Message=sayDeath(State.id)
	 else
	    Message=sayDamageTaken(State.id 2 State.life-2)
	    {Record.adjoin State player(life:State.life-2)}
	 end
      else
	 if (({Number.abs Position.y-State.pos.y}+{Number.abs Position.x-State.pos.x})<2) then
	    if State.life < 2 then
	       {Record.adjoin State player(life:State.life-State.life)}
	       Message=sayDeath(State.id)
	    else
	       Message=sayDamageTaken(State.id 1 State.life-1)
	       {Record.adjoin State player(life:State.life-1)}
	    end
	 else
	    Message=sayDamageTaken(State.id 0 State.life)
	    State
	 end
      end
   end

   /*
    * Answer the question given in the drone
    */
   fun{SayPassingDrone Drone State}
      case Drone of drone(row X) then
	 if State.pos.x==X then true
	 else false
	 end
      [] drone(column Y) then
	 if State.pos.y==Y then true
	 else false
	 end
      else false
      end
   end

   /*
    * Answer the question by giving a position with one coordinate right and the other wrong
    */
   fun{SayPassingSonar State}
      local R in
	 R={Random 2}
	 if R==1 then
	    pt(x:State.pos.x y:{Random Input.nColumn})
	 else
	    pt(x:{Random Input.nRow} y:State.pos.y)
	 end
      end
   end

   /*
    * Move the player at a right position
    */
   fun{Move ?Position ?Direction State}
      if(State.nbMove==1) then
	 Direction=surface
	 Position=State.pos
	 {Record.adjoin State player(nbMove:6 immersed:false path:Position|nil)}
      else
	 local ListPosDir in
	    ListPosDir =  {GetNewPos State [east north west south]}
	    if ListPosDir==nil then
	       Direction=surface
	       Position=State.pos
	       {Record.adjoin State player(nbMove:6 immersed:false path:Position|nil)}
	    else
	       Position=ListPosDir.1
	       Direction=ListPosDir.2
	       {Record.adjoin State player(pos:Position nbMove:State.nbMove-1 path:Position|State.path)}
	    end
	 end
      end
   end

   /*
    * Charge : 1)sonar, 2)drone and 3)missiles (until the death of the ennemies) => we check the case 1 2 3 via the variable item
    */
   fun{ChargeItem ?KindItem State}
      local PosItem ChargeItem2 in
	 fun{ChargeItem2 TempItem}
	    case TempItem of mine then
	       if State.loadMine+1==Input.mine then
		  KindItem=mine
		  {Record.adjoin State player(loadMine:0 numberMine:State.numberMine+1)}
	       else
		  KindItem=null
		  {Record.adjoin State player(loadMine:State.loadMine+1)}
	       end
	    [] missile then
	       if State.loadMissile+1==Input.missile then
		  KindItem=missile
		  {Record.adjoin State player(loadMissile:0 numberMissile:State.numberMissile+1)}
	       else
		  KindItem=null
		  {Record.adjoin State player(loadMissile:State.loadMissile+1)}
	       end
	    [] drone then
	       if State.loadDrone+1==Input.drone then
		  KindItem=drone
		  {Record.adjoin State player(loadDrone:0 numberDrone:State.numberDrone+1 item:2)}
	       else
		  KindItem=null
		  {Record.adjoin State player(loadDrone:State.loadDrone+1)}
	       end
	    [] sonar then
	       if State.loadSonar+1==Input.sonar then
		  KindItem=sonar
		  {Record.adjoin State player(loadSonar:0 numberSonar:State.numberSonar+1 item:1)}
	       else
		  KindItem=null
		  {Record.adjoin State player(loadSonar:State.loadSonar+1)}
	       end
	    end
	 end
	 {ChargeItem2 missile}
      end
   end

   /*
    * Choose wich item to lauch (which one is valid)
    */
   fun {ValidItem ListFire State}
      if ListFire==nil then nil
      else
	 case ListFire.1 of mine then
	    if State.numberMine>0 then
	       mine|{ValidItem ListFire.2 State}
	    else
	       {ValidItem ListFire.2 State}
	    end
	 [] missile then
	    if State.numberMissile>0 then
	       missile|{ValidItem ListFire.2 State}
	    else
	       {ValidItem ListFire.2 State}
	    end
	 [] drone then
	    if State.numberDrone>0 then
	       drone|{ValidItem ListFire.2 State}
	    else
	       {ValidItem ListFire.2 State}
	    end
	 [] sonar then
	    if State.numberSonar>0 then
	       sonar|{ValidItem ListFire.2 State}
	    else
	       {ValidItem ListFire.2 State}
	    end
	 [] rien then rien|{ValidItem ListFire.2 State}
	 end
      end
   end

   /*
    * Fire the item
    */
   fun{FireItem ?KindFire State}
      local Fire in
	 Fire={ValidItem [missile sonar drone mine rien]  State}.1
	 case Fire of mine then
	    KindFire=mine(State.pos)
	    {Record.adjoin State player(listMine:KindFire|State.listMine numberMine:State.numberMine-1)}
	 [] missile then
	    KindFire=missile({RandomPosition Input.map})
	    {Record.adjoin State player(numberMissile:State.numberMissile-1)}
	 [] drone then
	    KindFire=drone(row:{Random Input.nRow})
	    {Record.adjoin State player(numberDrone:State.numberDrone-1)}
	 [] sonar then
	    KindFire=sonar
	    {Record.adjoin State player(numberSonar:State.numberSonar-1)}
	 else
	    KindFire=null
	    State
	 end
      end
   end

   /*
    * Fire the first mine of the list listMine
    */
   fun{FireMine ?Mine State}
      if State.listMine==nil then
	 Mine=null
	 State
      else
	 Mine=State.listMine.1.1 %first object first argument (which is position)
	 {Record.adjoin State player(listMine:{RemoveFromList State.listMine State.listMine.1})}
      end
   end

   fun{StartPlayer Color ID}
      Stream
      Port
      PlayerState
   in
      PlayerState = player(id:id(id:ID color:Color name:randomIA) path:nil nbMove:6 pos:nil immersed:false life:Input.maxDamage listMine:nil loadMine:0 numberMine:0 loadMissile:0 numberMissile:0 loadDrone:0 numberDrone:0 loadSonar:0 numberSonar:0)
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
	    Newstate={Record.adjoin State player(pos:Position path:Position|nil)}
	    {TreatStream T Newstate}
	 end

      [] move(ID ?Position ?Direction)|T then
	 ID=State.id
	 local Newstate in
	    Newstate={Move ?Position ?Direction State}
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
	    Newstate={ChargeItem ?KindItem State}
	    {TreatStream T Newstate}
	 end

      [] fireItem(?ID ?KindFire)|T then
	 ID=State.id
	 local Newstate in
	    Newstate={FireItem ?KindFire  State}
	    {TreatStream T Newstate}
	 end

      [] fireMine(?ID ?Mine)|T then
	 ID=State.id
	 local Newstate in
	    Newstate={FireMine ?Mine State}
	    {TreatStream T Newstate}
	 end

      [] isDead(?Answer)|T then
	 if State.life==0 then Answer=true
	 else Answer=false
	 end
	 {TreatStream T State}

      [] sayMove(ID Direction)|T then
	 {TreatStream T State}

      [] saySurface(ID)|T then
	 {TreatStream T State}

      [] sayCharge(ID KindItem)|T then
	 {TreatStream T State}

      [] sayMinePlaced(ID)|T then
	 {TreatStream T State}

      [] sayMissileExplode(ID Position ?Message)|T then %simon
	 local Newstate in
	    Newstate={SayMissileExplode ID.id Position Message State}
	    {TreatStream T Newstate}
	 end

      [] sayMineExplode(ID Position ?Message)|T then %simon
	 local Newstate in
	    Newstate={SayMineExplode ID.id Position Message State}
	    {TreatStream T Newstate}
	 end

      [] sayAnswerDrone(Drone ID Answer)|T then
	 {TreatStream T State}
      [] sayPassingDrone(Drone ?ID ?Answer)|T then
	 ID=State.id
	 Answer={SayPassingDrone Drone State}
	 {TreatStream T State}

      [] sayAnswerSonar(ID Answer)|T then
	 {TreatStream T State}
      [] sayPassingSonar(?ID ?Answer)|T then
	 ID=State.id
	 Answer={SayPassingSonar State}
	 {TreatStream T State}
      [] sayDeath(ID)|T then
	 {TreatStream T State}
      [] sayDamageTaken(ID Damage LifeLeft)|T then
	 {TreatStream T State}
      end
   end
end
