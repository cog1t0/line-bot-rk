IF(FREETYPE_FOUND)
SET(TESTS_FILES
	bug00132
)
ENDIF(FREETYPE_FOUND)

ADD_GD_TESTS()
