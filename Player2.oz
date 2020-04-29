functor
import
   Input at 'Input.ozf'
   Browser(browse:Browse)
   Player at 'Player.2ozf'
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
   TrouverMap
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

   %Je suppose qu'il n'existe aucune colonne avec que des 1
   fun {TrouverMap L} %testé et approuvé
      local TrouverMap2 in
	 fun {TrouverMap2 L1 X}
      pt(x:2 y:2)
	 end
	 {TrouverMap2 L 1}
      end
   end

   fun{ChargeItem ?KindItem State}
      {Browse 1}
   end

   fun{FireItem ?ID ?KindFire}
      {Browse 1}
   end

   fun{FireMine ?ID ?Mine}
      {Browse 1}
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

   fun{SayMissileExplode ID Position ?Message}
      {Browse 1}
   end

   fun{SayMineExplode ID Position ?Message}
      {Browse 1}
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

   fun{SayDeath ID}
      {Browse 1}
   end

   fun{SayDamageTaken ID Damage LifeLeft}
      {Browse 1}
   end

   fun{StartPlayer Color ID}
      Stream
      Port
      PlayerState
   in
      %immersed pour savoir si il est en surface ou pas
      PlayerState = player(id:ID color:Color path:_ pos:_ immersed:_ )%LoadMine:_)% NumberMine:_ LoadMissile:_ NumberMissile:_ LoadDrone:_ NumberDrone:_ LoadSonar:_ NumberSonar:_)
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
	 Position={TrouverMap Input.map}
	 local Newstate in
	    Newstate={Record.adjoin State player(path:Position|nil)}
	    {TreatStream T Newstate}
	 end
      [] move(?ID ?Position ?Direction)|T then
	 ID=State.id
	 local CandPos in
	    case Direction of east then CandPos=pt(x:State.pos.x y:State.pos.y+1)
	    [] south then CandPos=pt(x:State.pos.x+1 y:State.pos.y)
	    [] west then CandPos=pt(x:State.pos.x y:State.pos.y-1)
	    [] north then CandPos=pt(x:State.pos.x-1 y:State.pos.y)
	    [] surface then
	       local Newstate in
		  Newstate={Record.adjoin State player(immersed:false path:State.pos|nil)}
		  {TreatStream T Newstate}
	       end
	    end
	    if({IsValidPath State.path CandPos}==true) then
	       Position=CandPos
	       local Newstate in
		  Newstate={Record.adjoin State player(pos:Position path:Position|State.path)}
		  {TreatStream T Newstate}
	       end
	    end
	 end
	 {TreatStream T State}
      [] dive|T then
	 local Newstate in
	    Newstate={Record.adjoin State player(immersed:true)}
	    {TreatStream T Newstate}
	 end
      [] chargeItem(?ID ?KindItem)|T then
	 ID=State.id
	 local Newstate in
	    Newstate={Record.adjoin State {ChargeItem ?KindItem State}}
	    {TreatStream T Newstate}
	 end

      [] fireItem(?ID ?KindFire)|T then {FireItem ID KindFire 0}
	 {TreatStream T State}
      [] fireMine(?ID ?Mine)|T then {FireMine ID Mine 0}
	 {TreatStream T State}
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
      [] sayMissileExplode(ID Position ?Message)|T then {SayMissileExplode ID Position Message 0}
	 {TreatStream T State}
      [] sayMineExplode(ID Position ?Message)|T then {SayMineExplode ID Position Message 0}
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
      [] sayDamageTaken(ID Damage LifeLeft)|T then {SayDamageTaken ID Damage LifeLeft 0}
	 {TreatStream T State}
      end
   end

end
