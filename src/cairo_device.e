note
	description: "[
		CAIRO_DEVICE - non-owning view of a surface's backing device.
		Obtained from CAIRO_SURFACE.device; the surface owns the lifetime,
		so there is no destroy here - only status and synchronization.
	]"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	CAIRO_DEVICE

create {CAIRO_SURFACE}
	make_shared

feature {NONE} -- Initialization

	make_shared (a_handle: POINTER)
		require
			handle_not_null: a_handle /= default_pointer
		do
			handle := a_handle
		end

feature -- Access

	handle: POINTER

feature -- Status

	status: INTEGER
		do
			Result := c_device_status (handle)
		end

feature -- Synchronization

	flush: like Current
		do
			c_device_flush (handle)
			Result := Current
		end

	finish: like Current
		do
			c_device_finish (handle)
			Result := Current
		end

feature {NONE} -- C Externals

	c_device_status (a_d: POINTER): INTEGER
		external "C inline use %"simple_cairo.h%""
		alias "return sc_device_status((cairo_device_t*)$a_d);"
		end

	c_device_flush (a_d: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_device_flush((cairo_device_t*)$a_d);"
		end

	c_device_finish (a_d: POINTER)
		external "C inline use %"simple_cairo.h%""
		alias "sc_device_finish((cairo_device_t*)$a_d);"
		end

end
