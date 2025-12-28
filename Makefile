# Archive all inside .build/

.PHONY: all clean landingpage-dist

all:
	bash Resources/DevKit/scripts/archive.all.sh

clean:
	rm -rf .build/

landingpage-dist:
	pnpm --dir LandingPage run build
	rm -rf LandingPage/dist
	cp -R LandingPage/out LandingPage/dist
