const HDLD_CH_AA12 = "asg";
const HDLD_CH_AA12_DRUM = "asm";

class CH_HDAA12:HDWeapon{
	default{
		+hdweapon.fitsinbackpack
		obituary "%o was filled with lead by %k";
		weapon.selectionorder 31;
		weapon.slotnumber 3;
		weapon.slotpriority 1;
		weapon.bobrangex 0.31;
		weapon.bobrangey 0.9;
		weapon.bobspeed 2.5;
		weapon.kickback 30;
		scale 0.6;
		inventory.pickupmessage "You got the Assault Shotgun!";
		hdweapon.barrelsize 26,0.5,1;
		hdweapon.refid HDLD_CH_AA12;
		tag "Assault Shotgun";
		inventory.icon "A12PA0";
		hdweapon.ammo1 "CH_HDAA12Drum",1;
	}
	override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){return GetSpareWeaponRegular(newowner,reverse,doselect);}
	override double gunmass(){
		return 5+((weaponstatus[AA12_MAG]<0)?-0.5:(weaponstatus[AA12_MAG]*0.075));
	}
	override double weaponbulk(){
		int mg=weaponstatus[AA12_MAG];
		return (((mg*1.5)*ENC_SHELLLOADED)+195);
	}
	override void failedpickupunload(){
		failedpickupunloadmag(AA12_MAG,"CH_HDAA12Drum");
	}
	override void DropOneAmmo(int amt){
		if(owner){
			amt=clamp(amt,1,10);
			if(owner.countinv("HDShellAmmo"))owner.A_DropInventory("HDShellAmmo",amt*32);
			else owner.A_DropInventory("CH_HDAA12Drum",amt);
		}
	}
	override void ForceBasicAmmo(){
		owner.A_TakeInventory("HDShellAmmo");
		ForceOneBasicAmmo("CH_HDAA12Drum");
	}
	override void DrawSightPicture(
		HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl,
		bool sightbob,vector2 bob,double fov,bool scopeview,actor hpc
	){
		int cx,cy,cw,ch;
		[cx,cy,cw,ch]=screen.GetClipRect();
		sb.SetClipRect(
			-16+bob.x,-32+bob.y,32,40,
			sb.DI_SCREEN_CENTER
		);
		vector2 bobb=bob*1.1;
		sb.drawimage(
			"frntsite",(0,0)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP
		);
		sb.SetClipRect(cx,cy,cw,ch);

		if(bplayingid)sb.drawimage(
			"sgbaksit",(0,0)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
			alpha:0.9
		);
		else sb.fill(
			color(250,26,26,26),
			bob.x-10,bob.y+6,20,4,
			sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP
		);
	}
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			int nextmagloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("CH_HDAA12Drum")));
			if(nextmagloaded>=30){
				sb.drawimage("A12PC0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,scale:(1,1));
			}else if(nextmagloaded<1){
				sb.drawimage("A12PD0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextmagloaded?0.6:1.,scale:(1,1));
			}else sb.drawbar(
				"A12PC0","A12PE0",
				nextmagloaded,30,
				(-46,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);
			sb.drawnum(hpl.countinv("CH_HDAA12Drum"),-43,-8,sb.DI_SCREEN_CENTER_BOTTOM);
		}
		if(weaponstatus[AA12_SWITCHTYPE]!=1)sb.drawwepcounter(hdw.weaponstatus[AA12_AUTO],
			-22,-10,"RBRSA3A7","STBURAUT","STFULAUT"
		);
		sb.drawwepnum(hdw.weaponstatus[AA12_MAG],30);
		if(hdw.weaponstatus[AA12_CHAMBER]==2)sb.drawrect(-19,-11,3,1);
	}
	override string gethelptext(){
		LocalizeHelp();
		return
		LWPHELP_FIRE..StringTable.Localize("  Shoot\n")
		..LWPHELP_FIREMODE..StringTable.Localize("  Toggle FireMode\n")
		..LWPHELP_RELOAD..StringTable.Localize("  Reload\n")
		..LWPHELP_UNLOADUNLOAD
		;
	}
	override string,double getpickupsprite(bool usespare){
		string spr;
		int wep0=GetSpareWeaponValue(0,usespare);
		spr="A12P";
		if(GetSpareWeaponValue(ZM66S_MAG,usespare)<0)spr=spr.."B";
		else spr=spr.."A";
		return spr.."0",1.;
	}
	static double getshotpower(){return frandom(0.9,1.05);}
	static void Fire(actor caller,bool right,int choke=1){
		double shotpower=getshotpower();
		double spread=3.;
		double speedfactor=1.2;
		let sss=Slayer(caller.findinventory("Slayer"));
		if(sss){
			choke=sss.weaponstatus[right?SLAYS_CHOKE2:SLAYS_CHOKE1];
			sss.shotpower=shotpower;
		}

		choke=clamp(choke,0,7);
		spread=6.5-0.5*choke;
		speedfactor=1.+0.02857*choke;

		spread*=shotpower;
		speedfactor*=shotpower;
		vector2 barreladjust=(0.8,-0.05);
		if(right)barreladjust=-barreladjust;
		HDBulletActor.FireBullet(caller,"HDB_wad",xyofs:barreladjust.x,aimoffx:barreladjust.y);
		let p=HDBulletActor.FireBullet(caller,"HDB_00",xyofs:barreladjust.x,
			spread:spread,aimoffx:barreladjust.y,speedfactor:speedfactor,amount:10
		);
		distantnoise.make(p,"world/shotgunfar");
		caller.A_StartSound("weapons/chaa12fire",CHAN_WEAPON,CHANF_OVERLAP);
	}
	states{
	select0:
		A12A A 0{
			if(invoker.weaponstatus[AA12_MAG]==-1)
				setweaponstate("selectnodrum");
		}
		goto select0small;
	selectnodrum:
		A12B A 0;
		goto select0small;
	deselect0:
		#### # 0;
		goto deselect0small;
	ready:
		#### # 1{
			A_SetCrosshair(21);
			A_WeaponReady(WRF_ALL);
		}
		goto readyend;
	user3:
		#### # 0 A_MagManager("CH_HDAA12Drum");
		goto ready;
	altfire:
		goto chamber_manual;
	althold:
		goto nope;
	hold:
		#### # 0{
			if(
				invoker.weaponstatus[AA12_CHAMBER]==2  //live round chambered
				&&(
					invoker.weaponstatus[AA12_AUTO]==2  //full auto
				)
			)setweaponstate("fire2");
		}goto nope;
	user2:
	firemode:
		#### # 1{
			int canaut=invoker.weaponstatus[AA12_SWITCHTYPE];
			int maxmode=(canaut>0)?(canaut-1):1;
			int aut=invoker.weaponstatus[AA12_AUTO];
			if(aut>=maxmode)invoker.weaponstatus[AA12_AUTO]=0;
			else invoker.weaponstatus[AA12_AUTO]=2;
		}goto nope;
	fire:
		#### # 0;
	fire2:
		#### # 0{
			if(invoker.weaponstatus[AA12_CHAMBER]==2);
			else setweaponstate("chamber_manual");
		}
		#### # 0{
			if(invoker.weaponstatus[AA12_CHAMBER]==2){
				invoker.Fire(self,0); //shoot
				invoker.weaponstatus[AA12_CHAMBER]=1; //the chamber has a spent shell
				A_ZoomRecoil(0.9); //effects of recoil
				A_MuzzleClimb(
					0,0,
					-frandom(0.2,0.4),-frandom(0.6,1.),
					-frandom(0.4,0.7),-frandom(1.2,2.1),
					-frandom(0.4,0.7),-frandom(1.2,2.1)
				);
				A_EjectCasing("HDSpentShell",frandom(-1,2),(frandom(0.2,0.3),-frandom(7,7.5),frandom(0,0.2)),(0,0,-2));//visual effect for us to get the shell out
				invoker.weaponstatus[AA12_CHAMBER]=0; //take the shell out
			}
			if(invoker.weaponstatus[AA12_AUTO]==2)A_SetTics(1);
		}
		#### # 0 {
			if(invoker.weaponstatus[AA12_MAG]>0){
				invoker.weaponstatus[AA12_MAG]--;
				invoker.weaponstatus[AA12_CHAMBER]=2;
			}
		}
		#### # 6 offset(0,10){
			A_Overlay(-1,"flash");
		}
		#### # 0 A_ReFire();
		goto ready;
	flash:
		A12F A 2 bright;
		A12F B 2 bright;
		stop;
	unloadchamber:
		#### # 4 A_JumpIf(invoker.weaponstatus[AA12_CHAMBER]<1,"nope");
		#### # 10{
			class<actor>which=invoker.weaponstatus[AA12_CHAMBER]>1?"HDShellAmmo":"HDSpentShell";
			invoker.weaponstatus[AA12_CHAMBER]=0;
			A_SpawnItemEx(which,
				cos(pitch)*10,0,height*0.82-sin(pitch)*10,
				vel.x,vel.y,vel.z,
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
		}goto readyend;
	loadchamber:
		#### # 0 A_JumpIf(invoker.weaponstatus[AA12_CHAMBER]>0,"nope");
		#### # 0 A_JumpIf(!countinv("HDShellAmmo"),"nope");
		#### # 1 offset(0,34) A_StartSound("weapons/chaa12magpocket",9);
		#### # 1 offset(2,36);
		#### # 1 offset(2,44);
		#### # 1 offset(5,58);
		#### # 2 offset(7,70);
		#### # 6 offset(8,80);
		#### # 10 offset(8,87){
			if(countinv("HDShellAmmo")){
				A_TakeInventory("HDShellAmmo",1,TIF_NOTAKEINFINITE);
				invoker.weaponstatus[AA12_CHAMBER]=2;
				A_StartSound("weapons/chaa12chamber",8);
			}else A_SetTics(4);
		}
		#### # 3 offset(9,76);
		#### # 2 offset(5,70);
		#### # 1 offset(5,64);
		#### # 1 offset(5,52);
		#### # 1 offset(5,42);
		#### # 1 offset(2,36);
		#### # 2 offset(0,34);
		goto nope;
	user4:
	unload:
		#### # 0{
			invoker.weaponstatus[0]|=AA12_JUSTUNLOAD;
			if(
				invoker.weaponstatus[AA12_MAG]>=0
			)setweaponstate("unmag");
			else if(invoker.weaponstatus[AA12_CHAMBER]>0)setweaponstate("unloadchamber");
		}goto nope;
	reload:
		#### # 0{
			invoker.weaponstatus[0]&=~AA12_JUSTUNLOAD;
			bool nomags=HDMagAmmo.NothingLoaded(self,"CH_HDAA12Drum");
			if(invoker.weaponstatus[AA12_MAG]>=32)setweaponstate("nope");
			else if(
				invoker.weaponstatus[AA12_MAG]<1
				&&(
					pressinguse()
					||nomags
				)
			){
				if(
					countinv("HDShellAmmo")
				)setweaponstate("loadchamber");
				else setweaponstate("nope");
			}else if(nomags)setweaponstate("nope");
		}goto unmag;
	unmag:
		#### # 4 offset(2,34) A_SetCrosshair(21);
		#### # 4 offset(4,36);
		#### # 4 offset(10,38);
		#### # 15 offset(12,40);
		#### # 5 offset(15,45){
			A_MuzzleClimb(0.3,0.4);
		}
		#### # 0{
			int magamt=invoker.weaponstatus[AA12_MAG];
			if(magamt<0){
				setweaponstate("magout");
				return;
			}
			invoker.weaponstatus[AA12_MAG]=-1;
			A_StartSound("weapons/chaa12magunload",8,CHANF_OVERLAP);
			if(
				(!PressingUnload()&&!PressingReload())
				||A_JumpIfInventory("CH_HDAA12Drum",0,"null")
			){
				HDMagAmmo.SpawnMag(self,"CH_HDAA12Drum",magamt);
				setweaponstate("magout");
			}else{
				HDMagAmmo.GiveMag(self,"CH_HDAA12Drum",magamt);
				A_StartSound("weapons/chaa12magpocket",9);
				setweaponstate("pocketmag");
			}
		}
		goto reloadend;
	pocketmag:
		#### # 7 offset(34,54) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
	magout:
		#### # 0{
			if(invoker.weaponstatus[0]&AA12_JUSTUNLOAD)setweaponstate("reloadend");
			else setweaponstate("loadmag");
		}
		#### # 4 offset(10,36);
		#### # 2 offset(8,38);
		#### # 2 offset(4,36);
		#### # 2 offset(2,34);
	loadmag:
		#### # 0 A_StartSound("weapons/chaa12magpocket",9);
		#### # 6 offset(34,54) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
		#### # 7 offset(34,52) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
		#### # 30 offset(32,50);
		#### # 3 offset(32,49){
			let mmm=hdmagammo(findinventory("CH_HDAA12Drum"));
			if(mmm){
				invoker.weaponstatus[AA12_MAG]=mmm.TakeMag(true);
				A_StartSound("weapons/chaa12magload",8,CHANF_OVERLAP);
			}
			if(
				invoker.weaponstatus[AA12_MAG]<1
				||invoker.weaponstatus[AA12_CHAMBER]>0
			)setweaponstate("reloadend");
		}
	reloadend:
		A12A A 0{
			if(invoker.weaponstatus[AA12_MAG]==-1)
				setweaponstate("reloadenddrumless");
		}
		goto reloadendreal;
	reloadenddrumless:
		A12B A 0;
		goto reloadendreal;
	reloadendreal:
		#### # 3 offset(30,52);
		#### # 2 offset(20,46);
		#### # 1 offset(10,42);
		#### # 1 offset(5,38);
		#### # 1 offset(0,34);
		goto chamber_manual;
	chamber_manual:
		#### # 0 A_JumpIf(
			invoker.weaponstatus[AA12_MAG]<1
			||invoker.weaponstatus[AA12_CHAMBER]==2
		,"nope");
		#### # 0 offset(3,32){
			A_WeaponBusy();
			invoker.weaponstatus[AA12_MAG]--;
			invoker.weaponstatus[AA12_CHAMBER]=2;
		}
		#### # 3 offset(5,35) A_StartSound("weapons/chaa12chamber",8,CHANF_OVERLAP);
		#### # 1 offset(3,32);
		#### # 1 offset(2,31);
		goto nope;
	spawn:
		TNT1 A 1;
		A12P A -1{
			if(invoker.weaponstatus[AA12_MAG]<0)frame=1;
		}
		A12P # -1;
		stop;
}
	override void initializewepstats(bool idfa){
		weaponstatus[AA12_MAG]=32;
		weaponstatus[AA12_CHAMBER]=2;
		weaponstatus[AA12_AUTO]=0;
	}
}

enum aa12status{
	AA12_JUSTUNLOAD=1,
	AA12_REFLEXSIGHT=2,

	AA12_SEMIONLY=1,
	AA12_BURSTONLY=2,
	AA12_FULLONLY=3,

	AA12_FLAGS=0,
	AA12_MAG=1,
	AA12_CHAMBER=2, //0 empty, 1 spent, 2 loaded
	AA12_AUTO=3, //0 semi, 1 burst, 2 auto
	AA12_RATCHET=4,
	AA12_SWITCHTYPE=5,
	AA12_DOT=6,
};

class CH_HDAA12Drum:HDMagAmmo{
	default{
		scale 0.6;
		hdmagammo.roundtype "HDShellAmmo";
		hdmagammo.maxperunit 32;
		hdmagammo.magbulk 30;
		hdpickup.refid HDLD_CH_AA12_DRUM;
		tag "Assault Shotgun Magazine";
		inventory.pickupmessage "You got the Assault Shotgun Magazine!";
		//hdpickup.refid HDLD_NIMAG30;
	}
	override string,string,name,double getmagsprite(int thismagamt){
		string magsprite=(thismagamt>0)?"A12PC0":"A12PD0";
		return magsprite,"SHL1A0","HDShellAmmo",2.;
	}
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("CH_HDAA12");
	}
	states{
	spawn:
		A12P C -1;
		stop;
	spawnempty:
		A12P D -1 A_SpawnEmpty();
		stop;
	}
}
