functor
import
    Player1 at 'PlayerBasicAI.ozf'
    Player2 at 'Player.ozf'
    Player3 at 'PlayerBasicAI3.ozf'
    Player4 at 'Player2.ozf'



export
    playerGenerator:PlayerGenerator
define
    PlayerGenerator
in
    fun{PlayerGenerator Kind Color ID}
        case Kind
        of player1 then {Player1.portPlayer Color ID}
        [] player2 then {Player2.portPlayer Color ID}
        [] player3 then {Player3.portPlayer Color ID}
        [] player4 then {Player4.portPlayer Color ID}
        end
    end
end
