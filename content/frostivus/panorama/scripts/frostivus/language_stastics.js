(function() {
	var playerInfo = Game.GetPlayerInfo(Game.GetLocalPlayerID());
	var steamID64 = playerInfo.player_steamid;
	var steamIDPart = Number(steamID64.substring(3));
	var steamID32 = String(steamIDPart - 61197960265728);

	$.AsyncWebRequest( 'http://18.216.43.117:10010/SaveLanguage', 
    {
       type: 'POST',
       data: {steamid: steamID32, language: $.Language()},
       success: function( data )
       {
       }
    });
})();