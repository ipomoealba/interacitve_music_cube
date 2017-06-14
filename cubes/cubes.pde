import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioPlayer song;
FFT fft;

float specLow = 0.03;
float specMid = 0.125;
float specHi = 0.20;

float scoreLow = 0;
float scoreMid = 0;
float scoreHi = 0;

float oldScoreLow = scoreLow;
float oldScoreMid = scoreMid;
float oldScoreHi = scoreHi;

float scoreDecreaseRate = 25;

int nbCubes;
Cube[] cubes;


int nbMurs = 500;
Mur[] murs;
AudioInput in;
int bsize = 512;
void setup()
{
        fullScreen(P3D);
        minim = new Minim(this);
        // song = minim.loadFile("test1.mp3");
        // fft = new FFT(song.bufferSize(), song.sampleRate());
        in = minim.getLineIn(Minim.MONO, bsize, 44100);
        fft = new FFT(in.left.size(),44100);
        nbCubes = (int)(fft.specSize()*specHi);
        cubes = new Cube[nbCubes];
        murs = new Mur[nbMurs];
        for (int i = 0; i < nbCubes; i++) {
                cubes[i] = new Cube();
        }

        for (int i = 0; i < nbMurs; i+=4) {
                murs[i] = new Mur(0, height/2, 10, height);
        }

        for (int i = 1; i < nbMurs; i+=4) {
                murs[i] = new Mur(width, height/2, 10, height);
        }


        for (int i = 2; i < nbMurs; i+=4) {
                murs[i] = new Mur(width/2, height, width, 10);
        }

        for (int i = 3; i < nbMurs; i+=4) {
                murs[i] = new Mur(width/2, 0, width, 10);
        }

        background(0);
        // song.play(0);
}

void draw()
{
        fft.forward(in.mix);
        oldScoreLow = scoreLow;
        oldScoreMid = scoreMid;
        oldScoreHi = scoreHi;
        scoreLow = 0;
        scoreMid = 0;
        scoreHi = 0;

        for (int i = 0; i < fft.specSize()*specLow; i++)
        {
                scoreLow += fft.getBand(i)*2;
        }

        for (int i = (int)(fft.specSize()*specLow); i < fft.specSize()*specMid; i++)
        {
                scoreMid += fft.getBand(i)*2;
        }

        for (int i = (int)(fft.specSize()*specMid); i < fft.specSize()*specHi; i++)
        {
                scoreHi += fft.getBand(i)*2;
        }

        if (oldScoreLow > scoreLow) {
                scoreLow = oldScoreLow - scoreDecreaseRate;
        }

        if (oldScoreMid > scoreMid) {
                scoreMid = oldScoreMid - scoreDecreaseRate;
        }

        if (oldScoreHi > scoreHi) {
                scoreHi = oldScoreHi - scoreDecreaseRate;
        }

        float scoreGlobal = 0.66*scoreLow + 0.8*scoreMid + 1*scoreHi;

        background(scoreLow/100, scoreMid/100, scoreHi/100);


        for (int i = 0; i < nbCubes; i++)
        {

                float bandValue = fft.getBand(i);
                cubes[i].display(scoreLow, scoreMid, scoreHi, bandValue, scoreGlobal);
        }

        float previousBandValue = fft.getBand(0);
        float dist = -25;
        float heightMult = 2;

        for (int i = 1; i < fft.specSize(); i++)
        {
                float bandValue = fft.getBand(i)*(1 + (i/50));
                stroke(100+scoreLow, 100+scoreMid, 100+scoreHi, 255-i);
                strokeWeight(1 + (scoreGlobal/100));

                line(0, height-(previousBandValue*heightMult), dist*(i-1), 0, height-(bandValue*heightMult), dist*i);
                line((previousBandValue*heightMult), height, dist*(i-1), (bandValue*heightMult), height, dist*i);
                line(0, height-(previousBandValue*heightMult), dist*(i-1), (bandValue*heightMult), height, dist*i);

                line(0, (previousBandValue*heightMult), dist*(i-1), 0, (bandValue*heightMult), dist*i);
                line((previousBandValue*heightMult), 0, dist*(i-1), (bandValue*heightMult), 0, dist*i);
                line(0, (previousBandValue*heightMult), dist*(i-1), (bandValue*heightMult), 0, dist*i);

                line(width, height-(previousBandValue*heightMult), dist*(i-1), width, height-(bandValue*heightMult), dist*i);
                line(width-(previousBandValue*heightMult), height, dist*(i-1), width-(bandValue*heightMult), height, dist*i);
                line(width, height-(previousBandValue*heightMult), dist*(i-1), width-(bandValue*heightMult), height, dist*i);

                line(width, (previousBandValue*heightMult), dist*(i-1), width, (bandValue*heightMult), dist*i);
                line(width-(previousBandValue*heightMult), 0, dist*(i-1), width-(bandValue*heightMult), 0, dist*i);
                line(width, (previousBandValue*heightMult), dist*(i-1), width-(bandValue*heightMult), 0, dist*i);

                previousBandValue = bandValue;
        }

        for (int i = 0; i < nbMurs; i++)
        {
                float intensity = fft.getBand(i%((int)(fft.specSize()*specHi)));
                murs[i].display(scoreLow, scoreMid, scoreHi, intensity, scoreGlobal);
        }
}

class Cube {
float startingZ = -10000;
float maxZ = 1000;
float x, y, z;
float rotX, rotY, rotZ;
float sumRotX, sumRotY, sumRotZ;


Cube() {
        x = random(0, width);
        y = random(0, height);
        z = random(startingZ, maxZ);
        rotX = random(0, 1);
        rotY = random(0, 1);
        rotZ = random(0, 1);
}


void display(float scoreLow, float scoreMid, float scoreHi, float intensity, float scoreGlobal) {
        color displayColor = color(scoreLow*0.67, scoreMid*0.67, scoreHi*0.67, intensity*5);
        fill(displayColor, 255);
        color strokeColor = color(255, 150-(20*intensity));
        stroke(strokeColor);
        strokeWeight(1 + (scoreGlobal/300));
        pushMatrix();
        translate(x, y, z);
        sumRotX += intensity*(rotX/1000);
        sumRotY += intensity*(rotY/1000);
        sumRotZ += intensity*(rotZ/1000);

        rotateX(sumRotX);
        rotateY(sumRotY);
        rotateZ(sumRotZ);
        box(100+(intensity/2));
        popMatrix();
        z+= (1+(intensity/5)+(pow((scoreGlobal/150), 2)));
        if (z >= maxZ) {
                x = random(0, width);
                y = random(0, height);
                z = startingZ;
        }
}
}



class Mur {
float startingZ = -10000;
float maxZ = 50;
float x, y, z;
float sizeX, sizeY;

Mur(float x, float y, float sizeX, float sizeY) {
        this.x = x;
        this.y = y;
        this.z = random(startingZ, maxZ);
        this.sizeX = sizeX;
        this.sizeY = sizeY;
}


void display(float scoreLow, float scoreMid, float scoreHi, float intensity, float scoreGlobal) {
        color displayColor = color(scoreLow*0.67, scoreMid*0.67, scoreHi*0.67, scoreGlobal);
        fill(displayColor, ((scoreGlobal-5)/1000)*(255+(z/25)));
        noStroke();
        pushMatrix();
        translate(x, y, z);
        if (intensity > 100) intensity = 100;
        scale(sizeX*(intensity/100), sizeY*(intensity/100), 20);
        box(1);
        popMatrix();
        displayColor = color(scoreLow*0.5, scoreMid*0.5, scoreHi*0.5, scoreGlobal);
        fill(displayColor, (scoreGlobal/5000)*(255+(z/25)));
        pushMatrix();
        translate(x, y, z);
        scale(sizeX, sizeY, 10);
        box(1);
        popMatrix();
        z+= (pow((scoreGlobal/150), 2));
        if (z >= maxZ) {
                z = startingZ;
        }
}
}
