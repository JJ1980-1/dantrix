# dantrix
Pauseskærm til terminal: Den binære kode for Dannebrogs Emoji, faldende ned i rød &amp; hvid Matrix Stil.

### Installer ved at indsætte nedenstående, i din Terminal (Linux):

```bash
git clone https://github.com/JJ1980-1/dantrix.git
cd dantrix
chmod +x dantrix.sh
sh dantrix.sh
cd ..
rm -r dantrix
```

### Start dantrix Pauseskærm:

```bash
dan
```

### Du kan ændre hastigheden på Linje 81

```bash
sudo nano /usr/bin/dan
```

### Ga til linje 81 (allernederst).

1.00 = 1 Sekundt

```text
	    # Small delay
    81	    sleep 0.15
    82	done
```
