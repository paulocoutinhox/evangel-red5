package com.prsolucoes.server;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collection;
import java.util.GregorianCalendar;
import java.util.List;
import java.util.Set;
import java.util.Timer;
import java.util.TimerTask;

import org.apache.log4j.Logger;
import org.red5.server.adapter.MultiThreadedApplicationAdapter;
import org.red5.server.api.IConnection;
import org.red5.server.api.IScope;
import org.red5.server.api.Red5;
import org.red5.server.api.service.IServiceCapableConnection;

import com.prsolucoes.server.pojo.Player;

public class Application extends MultiThreadedApplicationAdapter  {

	private static final Logger log = Logger.getLogger(Application.class);
	private static Timer timerPlayersJoined;
	
	public boolean appStart(IScope app) {
		log.debug("APP_START");
		
		if (super.appStart(app) == false) {
			return false;
		}
		
		log.info("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
		log.info("+ Application started                                                          +");
		log.info("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
		
		GameObjects.players = new ArrayList<Player>();
		
		createTaskPlayersJoined();
		
		return true;
	}

	private void createTaskPlayersJoined() {
		timerPlayersJoined = new Timer();
		timerPlayersJoined.schedule(new TimerTask() {
			
			@Override
			public void run() {
				sendBroadCastPlayersJoined();
			}
			
		}, 0, 5000);
	}

	public boolean roomStart(IScope room) {
		log.debug("ROOM_START");
		
		if (super.roomStart(room) == false) {
			return false;
		}
		
		log.info("First player connect on this room");
		return true;
	}

	public boolean appConnect(IConnection conn, Object params[]) {
		log.debug("APP_CONNECT");

		String clientId = Red5.getConnectionLocal().getClient().getId();
		log.info("New player connected: " + clientId);
		
		Player player = new Player();
		player.setId(clientId);
		player.setName("Paulo");
		player.setDirection(3);
		player.setDistanceMovement(32);
		player.setExp(0);
		player.setHeight(64);
		player.setHp(0);
		player.setLevel(0);
		player.setMp(0);
		player.setPosX(512);
		player.setPosY(256);
		player.setPosZ(0);
		player.setTweenVelocity(0.3F);
		player.setWidth(64);
		player.setType("player_male_base");
		player.setLoggedIn(false);
		
		GameObjects.players.add(player);
		
		sendBroadCastPlayerJoin(player);
		
		return true;
	}

	public void roomDisconnect(IConnection conn) {
		log.debug("ROOM_DISCONNECT");
		
		super.roomDisconnect(conn);		
		log.info("Player disconnected from room: " + getCurrentPlayer().getId());
	}

	public void appDisconnect(IConnection conn) {
		log.debug("APP_DISCONNECT");
		
		Player player = getCurrentPlayer();
		player.setLoggedIn(false);
		
		super.appDisconnect(conn);
		
		log.info("Player disconnected and removed: " + player.getId());
		sendBroadCastPlayerLeave(player);
		removePlayer(player);
	}

	/**
	 * User login request
	 */
	public String login(String username, String password) {
		log.debug("LOGIN");
		
		if (username.equals("test") && password.equals("test"))
		{
			log.debug("New player logged: " + username);
			return "LOGIN_OK";
		}
		else
		{
			return "LOGIN_ERROR";
		}
	}
	
	/**
	 * User profile request
	 */
	public Player profile() {
		log.debug("PROFILE");
		
		Player player = getCurrentPlayer();
		                        
		return player;
	}
	
	/**
	 * Map name
	 */
	public String mapName() {
		log.debug("MAP_NAME");
		
		return "map1";
	}
	
	/**
	 * Login process OK
	 */
	public String loginProcessOK() {
		log.debug("LOGIN_PROCESS_OK");
		
		Player player = getCurrentPlayer();
		player.setLoggedIn(true);
		
		return "";
	}
	
	/**
	 * get players joined
	 */
	public List<Player> playersJoined() {
		log.debug("PLAYERS_JOINED");
		return getPlayersJoined();
	}
	
	/**
	 * When player move
	 */
	public Player playerMove(int direction) {
		log.debug("PLAYER_MOVE");
		
		Player player = getCurrentPlayer();
			
		int posX = player.getPosX();
		int posY = player.getPosY();
		
		switch(direction) {
			case 1:
				posY -= player.getDistanceMovement();
				break;
				
			case 2:
				posX += player.getDistanceMovement();
				break;
				
			case 3:
				posY += player.getDistanceMovement();
				break;
			
			case 4:
				posX -= player.getDistanceMovement();
				break;
		}
		
		Boolean canPlayerMove = canPlayerMoveByLastMovementTime(player);
		
		if (canPlayerMove == true) {
			canPlayerMove = canPlayerMoveByMapLimit(player, posX, posY);
		}
		
		if (canPlayerMove) {
			player.setDirection(direction);
			player.setPosX(posX);
			player.setPosY(posY);
			player.setLastMovement(new GregorianCalendar());
			
			sendBroadCastPlayerMove(player);
		}
		
		return player;
	}
	
	/**
	 * Verify if player can move checking their last movement time
	 * @param player
	 */
	private Boolean canPlayerMoveByLastMovementTime(Player player) {
		log.debug("CAN_PLAYER_MOVE_BY_LAST_MOVEMENT_TIME");
		
		Calendar requiredTime = new GregorianCalendar();
		requiredTime.add(Calendar.MILLISECOND, -(player.getMovementDelayMiliseconds()));
		
		return (player.getLastMovement().compareTo(requiredTime) <= 0); 
	}
	
	/**
	 * Verify if player can move checking if their position pass the map limit
	 * @param player
	 * @param posY 
	 * @param posX 
	 */
	private Boolean canPlayerMoveByMapLimit(Player player, int posX, int posY) {
		log.debug("CAN_PLAYER_MOVE_BY_MAP_LIMIT");
		
		Boolean result = false;
		
		if (posX < 0) {
			result = false;
		} else if (posX > 1600) {
			result = false;
		} else if (posY < 0) {
			result = false;
		} else if (posY > 1600) {
			result = false;
		} else {
			result = true;
		}
		
		return result; 
	}
	
	/**
	 * Get player by player id
	 */
	private Player getPlayerById(String id) {
		log.debug("GET_PLAYER_BY_ID");
		
		if (GameObjects.players != null && GameObjects.players.size() > 0) {
			for (Player player : GameObjects.players) {
				if (player.getId().equals(id)) {
					return player;
				}
			}
		}
			
		return null;
	}
	
	/**
	 * Get player by player id
	 */
	private Player getPlayerByConnection(IConnection conn) {
		log.debug("GET_PLAYER_BY_CONNECTION");
		
		if (GameObjects.players != null && GameObjects.players.size() > 0 && conn != null && conn.getClient() != null) {
			for (Player player : GameObjects.players) {
				if (player.getId().equals(conn.getClient().getId())) {
					return player;
				}
			}
		}
			
		return null;
	}
	
	/**
	 * Get current connected player
	 */
	private Player getCurrentPlayer() {
		log.debug("GET_CURRENT_PLAYER");

		try {
			return getPlayerById(Red5.getConnectionLocal().getClient().getId());
		} catch (Exception e) {
			return null;
		}
	}
	
	/**
	 * Remove current connected player from list
	 */
	private void removeCurrentPlayer() {
		log.debug("REMOVE_CURRENT_PLAYER");
		removePlayer(getCurrentPlayer());
	}
	
	/**
	 * Remove player from list
	 */
	private void removePlayer(Player player) {
		log.debug("REMOVE_PLAYER");
		GameObjects.players.remove(player);
	}
	
	private List<Player> getPlayersJoined() {
		log.debug("GET_PLAYERS_JOINED");
		
		Player player = getCurrentPlayer();
		List<Player> result = new ArrayList<Player>();
			
		for (Player p : GameObjects.players) {
			if (player == null || p != player) {
				result.add(p);
			}
		}
		
		log.debug("Players joined: " + result.size());
		
		return result;
	}
	
	private void sendBroadCastPlayerMove(Player player)
	{
		log.debug("SEND_BROADCAST_PLAYER_MOVE");
		
		Collection<Set<IConnection>> clients = scope.getConnections();

        for (Set<IConnection> connectionSet : clients) {
        	for (final IConnection connection : connectionSet) {
            	if (Red5.getConnectionLocal() != connection) {
                	((IServiceCapableConnection) connection).invoke("playerMove", new Object[] { 
                		player
                	});
                }
             }
        }
	}
	
	private void sendBroadCastPlayerLeave(Player player)
	{
		log.debug("SEND_BROADCAST_PLAYER_LEAVE");
		
		Collection<Set<IConnection>> clients = scope.getConnections();

        for (Set<IConnection> connectionSet : clients) {
        	for (final IConnection connection : connectionSet) {
            	if (Red5.getConnectionLocal() != connection) {
                	((IServiceCapableConnection) connection).invoke("playerLeave", new Object[] { 
                		player
                	});
                }
             }
        }
	}
	
	private void sendBroadCastPlayerJoin(Player player)
	{
		log.debug("SEND_BROADCAST_PLAYER_JOIN");
		
		Collection<Set<IConnection>> clients = scope.getConnections();

        for (Set<IConnection> connectionSet : clients) {
        	for (final IConnection connection : connectionSet) {
            	if (Red5.getConnectionLocal() != connection) {
                	((IServiceCapableConnection) connection).invoke("playerJoin", new Object[] { 
                		player
                	});
                }
             }
        }
	}
	
	private void sendBroadCastPlayersJoined()
	{
		log.debug("SEND_BROADCAST_PLAYERS_JOINED");
		
		Collection<Set<IConnection>> clients = scope.getConnections();

        for (Set<IConnection> connectionSet : clients) {
        	for (final IConnection connection : connectionSet) {
            	
        		Player currentPlayer = getPlayerByConnection(connection);
        		
        		if (currentPlayer.isLoggedIn() == true)
        		{
	            	
	        		((IServiceCapableConnection) connection).invoke("playersJoined", new Object[] { 
	            		getPlayersJoined()
	            	});
	        		
        		}
        		
            }
        }
	}
	
}