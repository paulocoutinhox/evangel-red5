package com.prsolucoes.server.pojo;

import java.util.Calendar;
import java.util.GregorianCalendar;

import org.red5.annotations.DontSerialize;


public class Player {
	
	private String id;
	private String name;
	private String type;
	private int direction;
	private int level;
	private int hp;
	private int mp;
	private int exp;
	private int posX;
	private int posY;
	private int posZ;
	private int width;
	private int height;
	private float tweenVelocity = 0.3F; 
	private int movementDelayMiliseconds = 300;
	private int distanceMovement;
	private boolean loggedIn = false;
	
	@DontSerialize
	private Calendar lastMovement = new GregorianCalendar();
	
	public Player() {
		super();
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getDirection() {
		return direction;
	}

	public void setDirection(int direction) {
		this.direction = direction;
	}

	public int getLevel() {
		return level;
	}

	public void setLevel(int level) {
		this.level = level;
	}

	public int getHp() {
		return hp;
	}

	public void setHp(int hp) {
		this.hp = hp;
	}

	public int getMp() {
		return mp;
	}

	public void setMp(int mp) {
		this.mp = mp;
	}

	public int getExp() {
		return exp;
	}

	public void setExp(int exp) {
		this.exp = exp;
	}

	public int getPosX() {
		return posX;
	}

	public void setPosX(int posX) {
		this.posX = posX;
	}

	public int getPosY() {
		return posY;
	}

	public void setPosY(int posY) {
		this.posY = posY;
	}

	public int getPosZ() {
		return posZ;
	}

	public void setPosZ(int posZ) {
		this.posZ = posZ;
	}

	public int getWidth() {
		return width;
	}

	public void setWidth(int width) {
		this.width = width;
	}

	public int getHeight() {
		return height;
	}

	public void setHeight(int height) {
		this.height = height;
	}

	public float getTweenVelocity() {
		return tweenVelocity;
	}

	public void setTweenVelocity(float tweenVelocity) {
		this.tweenVelocity = tweenVelocity;
	}

	public int getDistanceMovement() {
		return distanceMovement;
	}

	public void setDistanceMovement(int distanceMovement) {
		this.distanceMovement = distanceMovement;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public boolean isLoggedIn() {
		return loggedIn;
	}

	public void setLoggedIn(boolean loggedIn) {
		this.loggedIn = loggedIn;
	}

	public Calendar getLastMovement() {
		return lastMovement;
	}

	public void setLastMovement(Calendar lastMovement) {
		this.lastMovement = lastMovement;
	}

	public int getMovementDelayMiliseconds() {
		return movementDelayMiliseconds;
	}

	public void setMovementDelayMiliseconds(int movementDelayMiliseconds) {
		this.movementDelayMiliseconds = movementDelayMiliseconds;
	}
		
	
}
