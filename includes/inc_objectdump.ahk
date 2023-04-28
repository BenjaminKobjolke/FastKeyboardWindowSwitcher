ObjToString(obj)
{
	if (!IsObject(obj))
		return obj
	str := "`n{"
	for key, value in obj
		str .= "`n" key ": " ObjToString(value) ","
	return str "`n}"
}
