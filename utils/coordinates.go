package utils

const (
	IsoWidth  = 40
	IsoHeight = 20
)

func CartesianToIsometric(cartX, cartY float32) (float32, float32) {
	isoX := (cartX - cartY) * IsoWidth / 2
	isoY := (cartX + cartY) * IsoHeight / 2
	return isoX, isoY
}

func IsometricToCartesian(isoX, isoY float32) (float32, float32) {
	cartX := (isoX/IsoWidth + isoY/IsoHeight)
	cartY := (isoY/IsoHeight - isoX/IsoWidth)
	return cartX, cartY
}
