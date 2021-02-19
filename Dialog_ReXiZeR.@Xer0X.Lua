--[[
if true then return end --]]
--[[
             Xer0X (tm) CopyLeft (c) 2019-2021
          Super Ultra Extra Total Dialogs & Panels
              Auto ReXiZeR (tm) & MuVvier (tm)

        Resizes and moves all the Far Manager dialogs
                         with ease!
	-----------------------------------------------

        DISCLAIMER
        The script's administration is not responsible
        for  any  use,  or  misuse,  or  any  kind  of
        unexpected    or    disappointing    behaviour
        while   running   the   supplied   script.
        Use carefully on your own responsibility.
	-----------------------------------------------
]]

--[[ Save the file as:
%FARPROFILE%\Macros\scripts\Xer0X\Dialog_ReXiZeR.@XeR0X.Lua
]]

--[[	TODO SECTION:

1.) move configs above to ini-file

2.) add dialog/window GUIDs not to resize

3.) add specific handling to dialog/windows by it's GUIDs,
	i.e. apply certain rules to specific guids,
	as for example:
		a.) this windows (guids) always put in full screen
		b.) those do not ever touch
		c.) .. etc .. ?

4.) probably, improve isolation between windows types, currently it MAY interfere each other
	that is not critical, since switchin by F5 seems to work flawlessly

5.) add more modes ? as for example 60%, 70%, 80%, 90% ?

6.) to write thorough documentation to help people find it and use it

7.) (to fix) Too complex dialogs with many elements also hidden,
	as for example "plugin configuration/netbox/transfer settings"
	we are still not perfect.

8.) Probably fix to disk menu going centered

9.) Probably clean up the code related to performance,
	i.e. do not call resize dialog routine, when we only moving the dialog

]]
-- @@@ END OF TODO SECTION @@@

-- ### INFO BLOCK ###

local Info = package.loaded.regscript or function(...) return ... end
local nfo = Info { _filename or ...,
	name		= "Dialog_ReXiZeR.@Xer0X.Lua";
	description	= "Resizes and moves all the Far Manager internal windows";
	version		= "1.2.5";
	author		= "Xer0X";
	url		= "https://forum.farmanager.com/viewtopic.php?f=15&t=11924";
	id		= "2862E9F8-C65C-44F6-8C2A-FD609977DAED";
--	parent_id	= "";
--	minfarversion	= { 3, 0, 0, 4744, 0 };
--	files		= "*.cfg;*.ru.lng";
--	config		= function(nfo, name) end;
--	help		= function(nfo, name) end;
--	execute		= function(nfo, name) end;
--	disabled	= true;
	options		= {
		ACT_KEY_F5 = "F5",
		ACT_KEYS_ALL =
[[$(F5)		Alt$(F5)	RAlt$(F5)
CtrlAltRight	CtrlAltLeft	CtrlAltUp	CtrlAltDown
CtrlRAltRight	CtrlRAltLeft	CtrlRAltUp	CtrlRAltDown
RCtrlRAltRight	RCtrlRAltLeft	RCtrlRAltUp	RCtrlRAltDown
AltShiftRight	AltShiftLeft
RAltShiftRight	RAltShiftLeft
AltHome		AltEnd
AltPgUp		AltPgDn
CtrlNum7	CtrlNum8	CtrlNum9
CtrlNum4	CtrlNum5	CtrlNum6
		CtrlClear
CtrlNum1	CtrlNum2	CtrlNum3
CtrlAltR	RCtrlAltR
CtrlRAltR	RCtrlRAltR]],
	};
}

-- @@@ END OF THE INFO BLOCK @@@

-- ### SETTINGS SECTION ###
if not Xer0X then Xer0X = { } end
-- "margin" ==> "full" ==> "original" ==> custom (if have) ==> "percent" ==> "margin" ==> "full" ==> (.. and so on)
local widmod_start = "WidthMargin"
local widmod_margin_width	=  4
local widmod_percent_width	= 70
local opts = nfo.options
local ACT_KEY_F5	= opts.ACT_KEY_F5
local ACT_KEYS_ALL	= string.gsub(opts.ACT_KEYS_ALL, "%$%(F5%)", ACT_KEY_F5)
-- @@@ END OF SETTINGS SECTION @@@

-- ### CONSTANTS ###
local F = far.Flags
local ACTL_GETWINDOWINFO= F.ACTL_GETWINDOWINFO
local DE_DLGPROCEND	= F.DE_DLGPROCEND
local DE_DLGPROCINIT	= F.DE_DLGPROCINIT
local DIF_HIDDEN	= F.DIF_HIDDEN
local DI_FIXEDIT	= F.DI_FIXEDIT
local DI_TEXT		= F.DI_TEXT
local DM_CLOSE		= F.DM_CLOSE
local DM_GETDIALOGINFO	= F.DM_GETDIALOGINFO
local DM_GETDIALOGTITLE	= F.DM_GETDIALOGTITLE
local DM_GETDLGRECT	= F.DM_GETDLGRECT
local DM_GETITEMPOSITION= F.DM_GETITEMPOSITION
local DM_GETTEXT	= F.DM_GETTEXT
local DM_LISTGETITEM	= F.DM_LISTGETITEM
local DM_LISTGETTITLES	= F.DM_LISTGETTITLES
local DM_LISTSETTITLES	= F.DM_LISTSETTITLES
local DM_MOVEDIALOG	= F.DM_MOVEDIALOG
local DM_RESIZEDIALOG	= F.DM_RESIZEDIALOG
local DM_SETITEMPOSITION= F.DM_SETITEMPOSITION
local DM_SETTEXT	= F.DM_SETTEXT
local DN_CLOSE		= F.DN_CLOSE
local DN_DRAWDIALOGDONE	= F.DN_DRAWDIALOGDONE
local DN_ENTERIDLE	= F.DN_ENTERIDLE
local DN_INITDIALOG	= F.DN_INITDIALOG
local DN_INPUT		= F.DN_INPUT
local DN_CONTROLINPUT	= F.DN_CONTROLINPUT
local DN_GOTFOCUS	= F.DN_GOTFOCUS
local DN_KILLFOCUS	= F.DN_KILLFOCUS
local DN_LISTCHANGE	= F.DN_LISTCHANGE
local DN_RESIZECONSOLE	= F.DN_RESIZECONSOLE
local PN_CHECKMASK	= F.PN_CHECKMASK	-- 0x00030000 196608
local PN_CMPNAME	= F.PN_CMPNAME		-- 0x00000000 0
local PN_CMPNAMELIST	= F.PN_CMPNAMELIST	-- 0x00010000 65536
local PN_GENERATENAME	= F.PN_GENERATENAME	-- 0x00020000 131072
local PN_NONE		= F.PN_NONE		-- 0x00000000 0
local PN_SHOWERRORMESSAGE=F.PN_SHOWERRORMESSAGE	-- 0x02000000 33554432
local PN_SKIPPATH	= F.PN_SKIPPATH		-- 0x01000000 16777216
local KEY_EVENT		= F.KEY_EVENT

local GUID_ZERO			= "00000000-0000-0000-0000-000000000000"
local LUACHECK_RESULT_MENU_ID	= "CFD31C22-0D17-4D87-829A-14561B529D34"
local FAR_EXIT_MSG_DLG_ID_TXT	= "4EBBEFC8-2084-4B7F-94C0-692CE136894D"
local LUA_EXPLORE_MENU_ID_TXT	= "7646F761-8954-42CA-9CFC-E3F98A1C54D3"
local FAR_EXIT_MSG_DLG_ID_BIN	= win.Uuid(FAR_EXIT_MSG_DLG_ID_TXT)
local tbl_menu_areas = { Menu = 1, UserMenu = 1, MainMenu = 1, Disks = 1, ShellAutoCompletion = 1, DialogAutoCompletion = 1 }

require("Lib-Common-@Xer0X")
require("introspection-@Xer0X")

local fnc_file_whoami		= Xer0X.fnc_file_whoami
local fnc_str_trim1		= Xer0X.fnc_str_trim1
local fnc_trim_R		= Xer0X.fnc_str_trim_right
local fnc_norm_menu_value	= Xer0X.fnc_norm_menu_value
local fnc_norm_guid		= Xer0X.fnc_norm_guid
local fnc_file_exists		= Xer0X.fnc_file_exists
local fnc_tbl_copy		= Xer0X.fnc_tbl_copy

local	is_mdl, tbl_args, own_file_path, own_file_fold, own_file_name, own_file_extn, p7, p8, p9, p10, p11
		= fnc_file_whoami({ ... })

local	lng_file_path = own_file_path..".Lng"
local	lng_msg = loadfile(lng_file_path)("load_as_module")

local	dlg_file_path, far2dlg
do      dlg_file_path = own_file_fold.."far2x_dialog"..own_file_extn
end
if not	Xer0X.fnc_file_exists(dlg_file_path)
then	dlg_file_path = own_file_fold.."dialog"..own_file_extn
end
if	Xer0X.fnc_file_exists(dlg_file_path)
then	far2dlg = loadfile(dlg_file_path)("load_as_module")
else	far2dlg = require("far2x.dialog")
end

local	hist_file_path, far2_hist
do	hist_file_path = own_file_fold.."far2x_history"..own_file_extn
end
if not	Xer0X.fnc_file_exists(hist_file_path)
then	hist_file_path = own_file_fold.."history"..own_file_extn
end
if	Xer0X.fnc_file_exists(hist_file_path)
then	far2_hist = loadfile(hist_file_path)("load_as_module")
else	far2_hist = require("far2x.history")
end

local dlg_cfg_id = win.Uuid("1FBED427-CA04-45CE-A3AB-1DCF1785AC98")
local hist_sett_db_key = "ReXiZeR-key-@Xer0X"
local hist_sett_db_name= "ReXiZeR-DB-@Xer0X"
local hist_data = far2_hist.newsettings(hist_sett_db_key, hist_sett_db_name)
local cfg_default = {
	ReloadDefaultScript	= false,
	RequireWithReload	= true,
	ReturnToMainMenu	= false,
	UseStrict		= true,
}
local cfg_current = hist_data:field("RexiZeR-PluginSettings")
setmetatable(cfg_current, { __index = cfg_default })
local dmp_srlz = require("dmp-tbl-alt-@Xer0X")
local	_evt, _fde, cfg_file_path, dat_file_path,
	_dlg_info_mcr, _dlg_info_evt, _dlg_info, _hDlg_mcr, _hDlg_evt, _hDlg,
	_dlg_guid_mcr, _dlg_guid_evt, _dlg_guid, _dlg_guid_own_mcr, _dlg_guid_own_evt, _dlg_guid_own,
	_dlg_xuid, _last_key, _last_area, _has_own_F5, _cons_gmtr

local _dlg_handles = { }
local _dlg_data = { }
local _dlg_safe_ids = { }
local _dlg_id_stats = { }
local _dlg_exc_ret_ids = { }
local _dlg_volt_items = { }
local _plg_safe_ids = { }


local function fnc_dlg_conf_store()
	local res_val, file_hnd
	local tbl_save_opts = {
		file_path	= cfg_file_path,
		file_init	= 1,
		file_append	= 1
	}
	tbl_save_opts.file_prext = "\n-- safe dialog guids: \n"
	res_val, file_hnd = dmp_srlz.fnc_file_save(_dlg_safe_ids, tbl_save_opts)
	tbl_save_opts.file_init  = nil
	tbl_save_opts.file_prext = ",\n-- safe plugin guids: \n"
	res_val, file_hnd = dmp_srlz.fnc_file_save(_plg_safe_ids, tbl_save_opts)
	tbl_save_opts.file_prext = ",\n-- do not restore current value of these menus: \n"
	res_val, file_hnd = dmp_srlz.fnc_file_save(_dlg_exc_ret_ids, tbl_save_opts)
	tbl_save_opts.file_prext = ",\n-- volatile (changeable) menu items:\n"
	res_val, file_hnd = dmp_srlz.fnc_file_save(_dlg_volt_items, tbl_save_opts)
	tbl_save_opts.file_close = 1
	tbl_save_opts.file_prext = ",\n-- just an example of serializing to a preexisting file: \n"
	res_val, file_hnd = dmp_srlz.fnc_file_save({a = 111, b = 222, "aaa", "bbb", "ccc", { val1 = 123, val2 = 345, val3 = 678 } }, tbl_save_opts)
	tbl_save_opts.file_prext = nil
	res_val, file_hnd = dmp_srlz.fnc_file_save(nil, tbl_save_opts)
end -- fnc_dlg_conf_store

local function fnc_dlg_data_store()
	local t_start = Far.UpTime
	local tbl_save_opts = {
		file_path	= dat_file_path,
		file_init	= 1,
		file_multi	= 1,
		file_append	= 1
	}
	local res_val, file_hnd = dmp_srlz.fnc_file_save(nil, tbl_save_opts)
	tbl_save_opts.file_init = nil
	for	ii_key, ii_val in next, _dlg_data
	do	if	ii_val.wid_cust
		or	ii_val.widmod
		or	ii_val.posmod
		or	ii_val.menu_pos_sel
		then	res_val, file_hnd = dmp_srlz.fnc_file_save(
			{ -- only certain parts of ii_val:
				text_head	= ii_val.text_head	,
				text_foot	= ii_val.text_foot	,
				posmod		= ii_val.posmod		,
				widmod		= ii_val.widmod		,
				wid_cust	= ii_val.wid_cust	,
				menu_pos_sel	= ii_val.menu_pos_sel	,
				menu_pos_top	= ii_val.menu_pos_top	,
				menu_val_str	= ii_val.menu_val_str	,
				named_id	= ii_val.named_id	,
			},
			tbl_save_opts, ii_key, true -- = Sorted by key
				)
		end
	end
	tbl_save_opts.file_init  = nil
	tbl_save_opts.file_multi = nil
	tbl_save_opts.file_prext = "},\n-- lets try to learn which ids are safe: \n"
	res_val, file_hnd = dmp_srlz.fnc_file_save(_dlg_id_stats, tbl_save_opts)
	tbl_save_opts.file_close = 1
	tbl_save_opts.file_prext = "\n-- Done in "..(Far.UpTime - t_start).." ms\n"
	res_val, file_hnd = dmp_srlz.fnc_file_save(nil, tbl_save_opts)
end -- fnc_dlg_data_store

do
	tbl_far_guid_names = Xer0X.tbl_far_guid_names
	dat_file_path = own_file_path..".Dat"
	local	dat_file_loaded, dat_file_error = loadfile(dat_file_path)
	if	dat_file_loaded
	then	_dlg_data, _dlg_id_stats = dat_file_loaded()
	end
	cfg_file_path = own_file_path..".Cfg"
	local	cfg_file_loaded, cfg_file_error = loadfile(cfg_file_path)
	if	cfg_file_loaded
	then	_dlg_safe_ids,
		_plg_safe_ids,
		_dlg_exc_ret_ids,
		_dlg_volt_items
			= cfg_file_loaded()
	end
	if not  _dlg_exc_ret_ids	then _dlg_exc_ret_ids	= { } end
	if not	_dlg_data		then _dlg_data		= { } end
	if not	_dlg_safe_ids		then _dlg_safe_ids	= { } end
	if not	_plg_safe_ids		then _plg_safe_ids	= { } end
	if not	_dlg_volt_items		then _dlg_volt_items	= { } end
	if not	_dlg_safe_ids[far.Guids.HistoryEditViewId]		then _dlg_safe_ids[far.Guids.HistoryEditViewId] 		= 1 end
	if not	_dlg_safe_ids[far.Guids.HistoryFolderId]		then _dlg_safe_ids[far.Guids.HistoryFolderId]			= 1 end
	if not	_dlg_safe_ids[far.Guids.HistoryCmdId]			then _dlg_safe_ids[far.Guids.HistoryCmdId]			= 1 end
	if not	_dlg_safe_ids[far.Guids.FiltersMenuId]			then _dlg_safe_ids[far.Guids.FiltersMenuId]			= 1 end
	if not	_dlg_safe_ids[far.Guids.FiltersConfigId]		then _dlg_safe_ids[far.Guids.FiltersConfigId]			= 1 end
	if not	_dlg_safe_ids[far.Guids.ChangeDiskMenuId]		then _dlg_safe_ids[far.Guids.ChangeDiskMenuId]			= 1 end
	if not	_dlg_safe_ids[FAR_EXIT_MSG_DLG_ID_TXT]			then _dlg_safe_ids[FAR_EXIT_MSG_DLG_ID_TXT]			= 1 end
	if not	_dlg_safe_ids[LUACHECK_RESULT_MENU_ID]			then _dlg_safe_ids[LUACHECK_RESULT_MENU_ID]			= 1 end
	if not	_dlg_safe_ids[LUA_EXPLORE_MENU_ID_TXT]			then _dlg_safe_ids[LUA_EXPLORE_MENU_ID_TXT]			= 1 end
	if not	_dlg_safe_ids["23B390E8-D91D-4FF1-A9AB-DE0CEFFDC0AC"]	then _dlg_safe_ids["23B390E8-D91D-4FF1-A9AB-DE0CEFFDC0AC"]	= 1 end
	if not	_dlg_safe_ids["EE448906-EC7D-4EA7-BC2E-848F48CDDD39"]	then _dlg_safe_ids["EE448906-EC7D-4EA7-BC2E-848F48CDDD39"]	= 1 end
	if not	_dlg_safe_ids["1BAA6870-4D49-40E5-8D20-19FF4B8AC5E6"]	then _dlg_safe_ids["1BAA6870-4D49-40E5-8D20-19FF4B8AC5E6"]	= 1 end
	-- Hard links choice menu (@Xer0X):
	if not	_dlg_safe_ids["29DE1DD2-57AC-4FFE-904D-376D4A84A089"]	then _dlg_safe_ids["29DE1DD2-57AC-4FFE-904D-376D4A84A089"]	= 1 end
	-- FarNet RightWords:
	if not  _dlg_safe_ids["10435532-9BB3-487B-A045-B0E6ECAAB6BC"]	then _dlg_safe_ids["10435532-9BB3-487B-A045-B0E6ECAAB6BC"]	= 1 end
	-- Ignore Multi-Panel menus calling:
	if not _dlg_exc_ret_ids["4EAC7327-6C97-444B-AC6A-2FCCCBAA7210"] then _dlg_exc_ret_ids["4EAC7327-6C97-444B-AC6A-2FCCCBAA7210"]	= 1 end
	-- Ignore HardLinksChoice menu (@Xer0X):
	if not _dlg_exc_ret_ids["29DE1DD2-57AC-4FFE-904D-376D4A84A089"] then _dlg_exc_ret_ids["29DE1DD2-57AC-4FFE-904D-376D4A84A089"]	= 1 end
	--[[ Ignore Filters menu.
	TODO: differentiate macro calling against user (manual) calling ]]
	if not _dlg_exc_ret_ids[far.Guids.FiltersMenuId]		then _dlg_exc_ret_ids	[far.Guids.FiltersMenuId]		= 1 end
	if not _dlg_exc_ret_ids[LUACHECK_RESULT_MENU_ID]		then _dlg_exc_ret_ids	[LUACHECK_RESULT_MENU_ID]		= 1 end
	if not _dlg_exc_ret_ids[LUA_EXPLORE_MENU_ID_TXT]		then _dlg_exc_ret_ids	[LUA_EXPLORE_MENU_ID_TXT]		= 1 end
	if not _dlg_volt_items["MainMenu#"..GUID_ZERO]			then _dlg_volt_items	["MainMenu#"..GUID_ZERO] = { } end
	if	cfg_file_error
	or not	fnc_file_exists(cfg_file_path)
	then	fnc_dlg_conf_store()
	end
	_G.Xer0X.dlg_data = _dlg_data
	_G.Xer0X.dlg_handles = _dlg_handles
end


local _crc64 = require("CRC64-@XeR0X")

local function fnc_elem_is_inside_full(elem1, elem2) return
	elem2[2] <= elem1[2] and
	elem2[3] <= elem1[3] and
	elem2[4] >= elem1[4] and
	elem2[5] >= elem1[5]
end

local function fnc_dlg_elm_vs_elm(elm1_x1, elm1_y1, elm1_x2, elm1_y2, elm2_x1, elm2_y1, elm2_x2, elm2_y2)
	if elm1_y2 < elm1_y1 and elm1_y2 == 0 then elm1_y2 = elm1_y1 end
	if elm2_y2 < elm2_y1 and elm2_y2 == 0 then elm2_y2 = elm2_y1 end
	if elm2_x2 < elm2_x1 then elm2_x2 = elm2_x1 end
	if elm2_y2 < elm2_y1 then elm2_y2 = elm2_y1 end
	local is_inside_1 =
		elm1_x1 >= elm2_x1 and
		elm1_x1 <= elm2_x2 and
		elm1_y1 >= elm2_y1 and
		elm1_y1 <= elm2_y2
	local is_inside_2 =
		elm1_x2 >= elm2_x1 and
		elm1_x2 <= elm2_x2 and
		elm1_y2 >= elm2_y1 and
		elm1_y2 <= elm2_y2
	local is_border_1 = false
	if is_inside_1 then is_border_1 =
		elm1_x1 == elm2_x1 or
		elm1_x1 == elm2_x2 or
		elm1_y1 == elm2_y1 or
		elm1_y1 == elm2_y2
	end
	local is_border_2 = false
	if is_inside_2 then is_border_2 =
		elm1_x2 == elm2_x1 or
		elm1_x2 == elm2_x2 or
		elm1_y2 == elm2_y1 or
		elm1_y2 == elm2_y2
	end
	return is_inside_1, is_inside_2, is_border_1, is_border_2
end

local function fnc_dlg_elm_vs_all(dlg_elems, dlg_obsts, diel, diel_idx, start_idx)
	local el1_x1, el1_y1, el1_x2, el1_y2 = diel[2], diel[3], diel[4], diel[5]
	if el1_x2 < el1_x1 then return false, false, false, false, false, nil, -1 end
	local is_inside_1_1, is_inside_1_2, is_border_1_1, is_border_1_2 = false, false, false, false
	local elm_lim, elm_lim_idx = nil, -1
	for ii = start_idx, #dlg_elems, 1
	do	if ii ~= diel_idx and dlg_obsts[ii]
		then	local	elm2 = dlg_elems[ii]
			local	el2_x1, el2_y1, el2_x2, el2_y2 =
				elm2[2],elm2[3],elm2[4],elm2[5]
			if not	dlg_obsts[ii].B
			then	if dlg_obsts[ii].T == "X1" then el2_x1 = el2_x1 - 1 end
				if dlg_obsts[ii].T == "X2" then el2_x2 = el2_x2 - 1 end
			end
			is_inside_1_1, is_inside_1_2, is_border_1_1, is_border_1_2 = fnc_dlg_elm_vs_elm(
				el1_x1, el1_y1, el1_x2, el1_y2,
				el2_x1, el2_y1, el2_x2, el2_y2);
			if 	is_border_1_2
			or	dlg_obsts[ii].T == "X1" and el1_x2 > el2_x1
			or	dlg_obsts[ii].T == "X2" and el1_x2 > el2_x2
			then	elm_lim = elm2
				elm_lim_idx = ii
				break
			end
		end
	end
	return true, is_inside_1_1, is_inside_1_2, is_border_1_1, is_border_1_2, elm_lim, elm_lim_idx
end

local function fnc_widmod_state_machine(widmod, wid_cust)
	if not	widmod
	then	return	widmod_start
	elseif	widmod=="WidthMargin"
	then	return	"WidthFull"
	elseif	widmod=="WidthFull"
	then	return	"WidthOriginal"
	elseif	widmod=="WidthOriginal"
	and	wid_cust
	then	return	"WidthCustom"
	elseif	widmod=="WidthOriginal"
	and not wid_cust
	then	return	"WidthPercent"
	elseif	widmod=="WidthCustom"
	then	return	"WidthPercent"
	elseif	widmod=="WidthPercent"
	then	return	"WidthMargin"
	end
end

local function fnc_file_curr() return APanel.Selected and APanel.SelCount == 1 and panel.GetSelectedPanelItem(nil, 1, 1).FileName or APanel.Current end

local function fnc_rest_long_file_name(str_orig, max_size)
	if str_orig:len() < 15 then return; end
	local f_name_orig = fnc_file_curr()
	local str_rest, idx_test
	local	str_short, str_like, left_like, str_test
	local	pos_short, end_short = unicode.utf8.cfind(str_orig, "… ", nil, true)
	if	pos_short
	then	str_short = str_orig:sub(1, pos_short + 1)
		str_like  = str_orig:sub(1, pos_short - 1)
		left_like = false
	else	pos_short, end_short = unicode.utf8.cfind(str_orig, " …", nil, true)
	if	pos_short
	then	str_short = str_orig:sub(pos_short + 1, str_orig:len())
		str_like  = str_orig:sub(pos_short + 2, str_orig:len())
		left_like = true
	else	pos_short, end_short = unicode.utf8.cfind(str_orig, "…", nil, true)
	if	pos_short and pos_short == 1
	then	str_short = str_orig
		str_like  = str_orig:sub(2)
		left_like = true
	end end end
	if	str_like and not left_like
	then	local str_after = "\""..str_orig:sub(end_short)
		for ii = 1, str_short:len() do
			str_test = str_like:sub(ii)
			pos_short, end_short = unicode.utf8.cfind(f_name_orig, str_test, nil, "plain")
			if pos_short and pos_short == 1 then
				local str_before= str_orig:sub(1, ii - 1).."\""
				local trunc_size= max_size - str_before:len() - str_after:len()
				f_name_orig = far.TruncStr(f_name_orig:reverse(), trunc_size):reverse()
				str_rest = str_before..f_name_orig..str_after
				break
			end
		end
	elseif	str_like and left_like
	then	pos_short, end_short = unicode.utf8.cfind(f_name_orig:reverse(), str_like:reverse(), nil, true)
		if	pos_short
		and	pos_short == 1
		then	str_rest = far.TruncStr(f_name_orig, max_size - 6)
		end
	end
	return str_rest
end


local CTLs = {
	 [  0] = "TEXT"
	,[  1] = "VTXT"
	,[  2] = "SINGLE_BX"
	,[  3] = "DOUBLE_BX"
	,[  4] = "EDIT"
	,[  5] = "PASSWORD"
	,[  6] = "FIXEDT"
	,[  7] = "BUTTON"
	,[  8] = "CHECK_BX"
	,[  9] = "RADIOBTN"
	,[ 10] = "COMBO_BX"
	,[ 11] = "LIST_BX"
	,[255] = "USERCTL"
		}

local function fnc_trans_msg(status_msg, title, props)
	far.Message(status_msg, title, "", props)
	far.Timer(5000, function(caller)
		caller:Close();
		far.AdvControl("ACTL_REDRAWALL");
	end)
end

local tbl_widmod_types = {
	"WidthOriginal",
	"WidthCustom",
	"WidthPercent",
	"WidthMargin",
	"WidthFull",
		}

local tbl_widmod_ids = {}
for ii = 1, #tbl_widmod_types do
	tbl_widmod_ids[tbl_widmod_types[ii]] = ii
end

local tbl_posmod_types = {
	"AlignBottomLeft",	"AlignBottomCenter",	"AlignBottomRight",
	"AlignCenterLeft",	"AlignCenterCenter",	"AlignCenterRight",
	"AlignTopLeft",		"AlignTopCenter",	"AlignTopRight",
	"AlignLeftBottom",	"AlignCenterBottom",	"AlignRightBottom",
	"AlignLeftCenter",				"AlignRightCenter",
	"AlignLeftTop",		"AlignCenterTop",	"AlignRightTop",
	"AlignLeft",		"AlignRight",
	"AlignTop",		"AlignBottom",
	"AbsPos",
	"MoveLeft",		"MoveRight",
	"MoveUp",		"MoveDown",
	[-1] = "NOT-ALIGNED"
		}

local tbl_posmod_keys = {}
local tbl_posmod_ids = {}
local tbl_aligned = {}
for ii = 1, #tbl_posmod_types do
	local pos_mod_type = tbl_posmod_types[ii]
	if ii > 0 and ii < 10
	then	tbl_posmod_keys[pos_mod_type] = "CtrlNum"..ii
		tbl_posmod_keys["CtrlNum"..ii]= pos_mod_type
		tbl_posmod_keys[ii] = "CtrlNum"..ii
	elseif	pos_mod_type == "AbsPos"
	then
		tbl_posmod_keys[pos_mod_type] = "CtrlAltF123"
		tbl_posmod_keys["CtrlAltF123"]= pos_mod_type
		tbl_posmod_keys[ii] = "CtrlAltF123"
	end
	tbl_posmod_ids[pos_mod_type] = ii
	tbl_posmod_ids[ii] = pos_mod_type
	if string.find(pos_mod_type, "Align") == 1
	then	tbl_aligned[pos_mod_type] = true
		tbl_aligned[ii] = true
	end
end

local function fnc_posmod_key_fix(pos_mod, pos_key)
	if tbl_posmod_keys[pos_mod] then return end
	tbl_posmod_keys[pos_mod] = pos_key;
	tbl_posmod_keys[tbl_posmod_ids[pos_mod]]= pos_key;
end

fnc_posmod_key_fix("AlignLeftBottom"	, "CtrlNum1")
fnc_posmod_key_fix("AlignCenterBottom"	, "CtrlNum2")
fnc_posmod_key_fix("AlignRightBottom"	, "CtrlNum3")
fnc_posmod_key_fix("AlignLeftCenter"	, "CtrlNum4")
fnc_posmod_key_fix("AlignRightCenter"	, "CtrlNum6")
fnc_posmod_key_fix("AlignLeftTop"	, "CtrlNum7")
fnc_posmod_key_fix("AlignCenterTop"	, "CtrlNum8")
fnc_posmod_key_fix("AlignRightTop"	, "CtrlNum9")

local dlg_coord = {

	fnc_prep = function(self, dlg_gmtr)
-- ###
if not	self
then	self = {fnc_prep = debug.getinfo(1, "f").func,
		
	}
end
if	dlg_gmtr
then
	self.GM = dlg_gmtr
	self.X1 = dlg_gmtr.Left		or dlg_gmtr.X1 or self.X1
	self.Y1 = dlg_gmtr.Top		or dlg_gmtr.Y1 or self.Y1
	self.X2 = dlg_gmtr.Right	or dlg_gmtr.X2 or self.X2
	self.Y2 = dlg_gmtr.Bottom	or dlg_gmtr.Y2 or self.Y2
else
	if	Area.Dialog
	then	self.X1 = Dlg.GetValue(0, 2)
		self.Y1 = Dlg.GetValue(0, 3)
		self.X2 = Dlg.GetValue(0, 4)
		self.Y2 = Dlg.GetValue(0, 5)
	else	local dlg_info = far.AdvControl(ACTL_GETWINDOWINFO, nil)
		local dlg_hndl = dlg_info.Id
		local dlg_gmtr = dlg_hndl:send(DM_GETDLGRECT, 0, 0)
		self.GM = dlg_gmtr
		self.X1 = dlg_gmtr.Left
		self.Y1 = dlg_gmtr.Top
		self.X2 = dlg_gmtr.Right
		self.Y2 = dlg_gmtr.Bottom
	end
end
self.W = self.X2 - self.X1 + 1
self.H = self.Y2 - self.Y1 + 1
self.X = self.X1
self.Y = self.Y1
self.XC= math.abs((self.X2 + self.X1) - Far.Width ) < 3
self.YC= math.abs((self.Y2 + self.Y1) - Far.Height) < 3
self.align_id = nil
self.align_str= nil
if	self.X1 == 0 and
	self.Y1 == 0
then	self.align_id = 7
elseif	self.X2 == Far.Width and
	self.Y2 == Far.Height
then	self.align_id = 3
elseif	self.X2 == Far.Width and
	self.Y1 == 0
then	self.align_id = 9
elseif	self.X1 == 0 and
	self.Y2 == Far.Height
then	self.align_id = 1
elseif	self.X1 == 0 and
	self.YC
then	self.align_id = 4
elseif	self.XC and
	self.Y1 == 0
then	self.align_id = 8
elseif	self.X2 == Far.Width and
	self.YC
then	self.align_id = 6
elseif	self.XC and
	self.Y2 == Far.Height
then	self.align_id = 2
elseif	self.XC and
	self.YC
then	self.align_id = 5
end
if	self.align_id then
	self.align_str = tbl_posmod_types[self.align_id]
end
return	self
-- @@@ fnc_prep
	end
}


-- #############################################################################

function fnc_num_sign(the_num) return the_num > 0 and 1 or the_num < 0 and -1 or 0 end

-- ############################################################################

local function fnc_calc_move(the_key, the_mod, algndlr, gmtr_curr, gmtr_orig, wid_cust)

-- ###

local dlg_crd = dlg_coord.fnc_prep(nil,
	gmtr_curr and {
		X1 = gmtr_curr.Left	or gmtr_curr.X1,
		Y1 = gmtr_curr.Top	or gmtr_curr.Y1,
		X2 = gmtr_curr.Right	or gmtr_curr.X2,
		Y2 = gmtr_curr.Bottom	or gmtr_curr.Y1
			}
				)
local 	op_code,
	aligned,
	delta_X,
	delta_Y,
	delta_W,
	targetX,
	targetY,
	targetW,
	targetH

if	the_key =="AltHome"
-- Move the dialog to the left
then	op_code = "AlignLeft"
	delta_X = -dlg_crd.X1
	delta_Y = 0
elseif	the_key =="AltEnd"
-- Move the dialog to the right
then	op_code = "AlignRight"
	delta_X = Far.Width - dlg_crd.X2
	delta_Y = 0
elseif	the_key =="AltPgUp"
-- Move the dialog to the top
then	op_code = "AlignTop"
	delta_X = 0
	delta_Y = -dlg_crd.Y1
elseif	the_key =="AltPgDn"
-- Move the dialog to the bottom
then	op_code = "AlignBottom"
	delta_X = 0
	delta_Y = Far.Height - dlg_crd.Y2
elseif	the_key =="CtrlNum4"
-- Align the dialog to left-center
then	op_code = "AlignLeftCenter"
	delta_X = -dlg_crd.X1
	delta_Y = (Far.Height- dlg_crd.H) / 2 - dlg_crd.Y1
elseif	the_key =="CtrlNum1"
-- Align the dialog to bottom-left
then	op_code = "AlignBottomLeft"
	delta_X = -dlg_crd.X1
	delta_Y = Far.Height - dlg_crd.Y2
elseif	the_key =="CtrlNum6"
-- Align the dialog to right-center
then	op_code = "AlignRightCenter"
	delta_X = Far.Width  - dlg_crd.X2
	delta_Y = (Far.Height- dlg_crd.H) / 2 - dlg_crd.Y1
elseif	the_key =="CtrlNum9"
-- Align the dialog to top-right
then	op_code = "AlignTopRight"
	delta_X = Far.Width  - dlg_crd.X2
	delta_Y = -dlg_crd.Y1
elseif	the_key =="CtrlNum8"
-- Align the dialog to top-center
then	op_code = "AlignTopCenter"
	delta_X = (Far.Width - dlg_crd.W) / 2 - dlg_crd.X1
	delta_Y = -dlg_crd.Y1
elseif	the_key =="CtrlNum7"
-- Align the dialog to top-left
then	op_code = "AlignTopLeft"
	delta_X = -dlg_crd.X1
	delta_Y = -dlg_crd.Y1
elseif	the_key =="CtrlNum2"
-- Align the dialog to bottom-center
then	op_code = "AlignBottomCenter"
	delta_X = (Far.Width - dlg_crd.W) / 2 - dlg_crd.X1
	delta_Y = Far.Height - dlg_crd.Y2
elseif	the_key =="CtrlNum3"
-- Align the dialog to bottom-right
then	op_code = "AlignBottomRight"
	delta_X = Far.Width  - dlg_crd.X2
	delta_Y = Far.Height - dlg_crd.Y2
elseif	the_key =="CtrlClear" or
	the_key =="CtrlNum5"
-- Align the dialog to center-center
then	op_code = "AlignCenterCenter"
	delta_X = (Far.Width - dlg_crd.W) / 2 - dlg_crd.X1
	delta_Y = (Far.Height- dlg_crd.H) / 2 - dlg_crd.Y1
elseif	the_key =="CtrlAltRight"
then	op_code = "MoveRight"
	delta_X = 1
	delta_Y = 0
elseif	the_key =="CtrlAltLeft"
then	op_code = "MoveLeft"
	delta_X = -1
	delta_Y	= 0
elseif	the_key =="CtrlAltUp"
then	op_code = "MoveUp"
	delta_X = 0
	delta_Y = -1
elseif	the_key =="CtrlAltDown"
then	op_code = "MoveDown"
	delta_X = 0
	delta_Y = 1
elseif	the_key =="CtrlAltF123"
then	op_code = "AbsPos"
	targetX = the_mod.X
	targetY = the_mod.Y
elseif	the_key =="AltShiftRight"
then	op_code = "WidthCustom"
	targetW	= dlg_crd.W + 2
	--[[ good for single point (by 1) of move:
	delta_X = -1 * (targetW % 2) -- math.random(-1, 0) --]]
	delta_X =-2 / 2
elseif	the_key =="AltShiftLeft"
then	op_code = "WidthCustom"
	--[[ good for single point (by 1) of move:
	delta_X = 1 * (dlg_crd.W % 2) -- math.random(0, 1) --]]
	delta_X = 2 / 2
	targetW = dlg_crd.W - 2
elseif  the_key ==ACT_KEY_F5
then
	if	the_mod	=="WidthMargin"
	then	targetW = _cons_gmtr.W - widmod_margin_width
	elseif	the_mod	=="WidthPercent"
	then	targetW = math.floor(_cons_gmtr.W * widmod_percent_width / 100)
	elseif	the_mod	=="WidthFull"
	then	targetW = _cons_gmtr.W
	elseif	the_mod	=="WidthCustom" and wid_cust
	then	targetW = wid_cust
	elseif	the_mod	=="WidthOriginal"
	then	targetW = gmtr_orig.W
	end
	if 	targetW
	then	op_code = the_mod
		delta_X = math.floor((dlg_crd.W - targetW) / 2)
	end
end
if delta_X and delta_X == 0 and (not delta_Y or delta_Y == 0) then delta_X = nil end
if delta_Y and delta_Y == 0 and (not delta_X or delta_X == 0) then delta_Y = nil end
if delta_W and delta_W == 0 and (not delta_H or delta_H == 0) then delta_W = nil end
if	algndlr and
	math.abs(algndlr) > 0 and
	tbl_widmod_ids[op_code] and
	the_mod ~= "WidthOriginal" and
	the_mod ~= "WidthCustom"
then
	local alnlr_fix = algndlr * (targetW - _cons_gmtr.W) / 2
	targetX = math.floor((_cons_gmtr.W - targetW) / 2 + alnlr_fix)
end
local mid_stop
if op_code and string.find(op_code, "Align") == 1 then
	aligned = true
	if delta_X and math.abs(delta_X) > Far.Width / 2 + 5 then delta_X = math.floor(delta_X - fnc_num_sign(delta_X) * (Far.Width - dlg_crd.W) / 2); mid_stop = true end
	if delta_Y and math.abs(delta_Y) > Far.Height/ 2 + 3 then delta_Y = math.floor(delta_Y - fnc_num_sign(delta_Y) * (Far.Height- dlg_crd.H) / 2); mid_stop = true end
end
if aligned then
	dlg_crd:fnc_prep({
		X1 = (targetX or dlg_crd.X1) + (delta_X or 0);
		Y1 = (targetY or dlg_crd.Y1) + (delta_Y or 0);
			})
	dlg_crd:fnc_prep({
		X2 = targetW and (dlg_crd.X1 + targetW - 1) or dlg_crd.X2 + (delta_X or 0);
		Y2 = targetH and (dlg_crd.Y1 + targetH - 1) or dlg_crd.Y2 + (delta_Y or 0);
			})
	if dlg_crd.align_id and dlg_crd.align_id ~= tbl_posmod_ids[op_code] then
		op_code = dlg_crd.align_str
	end
end
return {
		the_key = the_key,
		the_mod = the_mod,
		op_code = op_code,
		aligned = aligned,
		algn_id = aligned and dlg_crd.align_id,
		aln_str = aligned and dlg_crd.align_str,
		delta_X = delta_X,
		delta_Y = delta_Y,
		delta_W = delta_W,
		targetX = targetX,
		targetY = targetY,
		targetW = targetW,
		targetH = targetH,
	},
	dlg_crd

-- @@@ fnc_calc_move(...)

end

local function fnc_layout_cmd_exec(layout_cmd, dlg_gmtr)
	local dlg_place, dlg_size
	if	layout_cmd.targetX or
		layout_cmd.delta_X
	then	dlg_place= far.SendDlgMessage(_hDlg, DM_MOVEDIALOG,
			layout_cmd.targetX and 1 or 0,
			layout_cmd.targetX and
				{ X = layout_cmd.targetX, Y = layout_cmd.targetY or dlg_gmtr.Y} or
				{ X = layout_cmd.delta_X, Y = layout_cmd.delta_Y or 0}
					)
	end
	if	layout_cmd.targetW
	then	dlg_size = far.SendDlgMessage(_hDlg, DM_RESIZEDIALOG,	0, { X = layout_cmd.targetW, Y = layout_cmd.targetH or dlg_gmtr.H })
	end
	return dlg_place, dlg_size
end

local function fnc_gmtr_calc(dlg_gmtr, dlg_place, dlg_size)
	dlg_gmtr.X	= dlg_place	and dlg_place.X	or dlg_gmtr.Left or dlg_gmtr.X1 or dlg_gmtr.X
	dlg_gmtr.Y	= dlg_place	and dlg_place.Y	or dlg_gmtr.Top	 or dlg_gmtr.Y1 or dlg_gmtr.Y
	dlg_gmtr.W	= dlg_size	and dlg_size.X	or
		dlg_gmtr.Left	and (dlg_gmtr.Right - dlg_gmtr.Left + 1) or
		dlg_gmtr.X1	and (dlg_gmtr.X2 - dlg_gmtr.X1 + 1) or
		dlg_gmtr.Width	or
		dlg_gmtr.W
	dlg_gmtr.H	= dlg_size	and dlg_size.Y	or
		dlg_gmtr.Bottom and (dlg_gmtr.Bottom - dlg_gmtr.Top + 1) or
		dlg_gmtr.Y1	and (dlg_gmtr.Y2 - dlg_gmtr.Y1 + 1) or
		dlg_gmtr.Height or
		dlg_gmtr.H
	dlg_gmtr.X1	= dlg_gmtr.X
	dlg_gmtr.Y1	= dlg_gmtr.Y
	dlg_gmtr.X2	= dlg_gmtr.X + dlg_gmtr.W - 1
	dlg_gmtr.Y2	= dlg_gmtr.Y + dlg_gmtr.H - 1
	dlg_gmtr.Left	= dlg_gmtr.X1
	dlg_gmtr.Top	= dlg_gmtr.Y1
	dlg_gmtr.Right	= dlg_gmtr.X2
	dlg_gmtr.Bottom	= dlg_gmtr.Y2
	dlg_gmtr.Width	= dlg_gmtr.W
	dlg_gmtr.Height	= dlg_gmtr.Height
	return dlg_gmtr
end

local function fnc_action(sender, msg, dlg_is_menu)
	
	local	cons_gmtr	= far.AdvControl("ACTL_GETFARRECT")
	local	cons_width	= cons_gmtr.Right	- cons_gmtr.Left+ 1
	local	cons_height	= cons_gmtr.Bottom	- cons_gmtr.Top	+ 1
	local	dlg_gmtr	= _hDlg:send(DM_GETDLGRECT, 0, 0)
	local 	dlg_width	= dlg_gmtr.Right	- dlg_gmtr.Left	+ 1
	local	dlg_height	= dlg_gmtr.Bottom	- dlg_gmtr.Top	+ 1
	local	dlg_algLR	= math.floor((Far.Width - dlg_gmtr.Right- dlg_gmtr.Left) / 2)
	local	dlg_afnLR	= (math.abs(dlg_algLR) > 3 and 1 or 0) * (dlg_algLR > 0 and 1 or -1)
	if	dlg_afnLR == 0
	then 	dlg_afnLR = nil
		dlg_algLR = nil
	end
	local	dlg_hnd_str = tostring(_hDlg)
	_cons_gmtr	= cons_gmtr
	_cons_gmtr.W	= cons_width
	_cons_gmtr.H	= cons_height
	fnc_gmtr_calc(dlg_gmtr)
	local	layout_cmd_wid, layout_cmd_pos, wid_mod, pos_mod, dei, deii, dio, is_menu, eltp,
		dlg_data, dlg_xuid, dlg_sign, dlg_titles, dlg_place, dlg_size, dlg_crd, targ_W,
		dlg_guid_0, dlg_guid_0_cnt, dlg_type_sign, crc64_t, crc64_s, file_curr,
		guess_area, wid_adj, is_safe_id,
		area_dlg_guid, tbl_volatiles
	local	dlg_elems, dlg_elszs, dlg_obsts, dlg_info_sign, tbl_layout_operations = {}, {}, {}, {}, {}
	local	dlg_guid	= _dlg_guid
	local	dlg_guid_own	= _dlg_guid_own
	if	dlg_guid
	then	dlg_guid_0, dlg_guid_0_cnt = dlg_guid:gsub("0", "")
		if dlg_guid_0_cnt > 6 then dlg_guid = nil end
	end
	local	dlg_guid_vlt = dlg_guid
	if	dlg_guid
	and	_dlg_safe_ids[dlg_guid]
	then	is_safe_id = true
	else
		if	dlg_guid_own
		then	dlg_guid = dlg_guid_own
		end
	end
	file_curr = fnc_file_curr()
	local t_crc_1 = Far.UpTime
	if not	is_safe_id
	then	crc64_t = _crc64:new()
	end
	for	deii = 1, math.huge, 1
	do
		local t_dlg_elm_get_1 = Far.UpTime
		dei = _hDlg:send(
			"DM_GETDLGITEM",
			deii)
		if not dei then break end
		local t_dlg_elm_get_2 = Far.UpTime
		local t_dlg_elm_get = t_dlg_elm_get_2 - t_dlg_elm_get_1
		local	tbl_list_items,	dei_6
		if	dei[1] == 10
		or	dei[1] == 11
		then	tbl_list_items = dei[6]
		end
		if t_dlg_elm_get > 0 then
		end
		dlg_elems[deii] = dei;
		dlg_elszs[deii] = { dei[1], dei[2], dei[3], dei[4], dei[5], dei[6], dei[7], dei[8], dei[9], dei[10]}
		if dei[4] == 0 then dlg_elszs[deii][4] = dei[2] end
		if dei[5] == 0 then dlg_elszs[deii][5] = dei[3] end
		area_dlg_guid = _dlg_handles[dlg_hnd_str].mcr_area.."#"..(dlg_guid or GUID_ZERO)
		tbl_volatiles = _dlg_volt_items[area_dlg_guid]
		if not	is_safe_id
		then	if	dlg_is_menu == "M"
			and (	dei[1] == 10
			or	dei[1] == 11)
			then	
				for ii_li = 1, math.min(#tbl_list_items, 1000)
				do	local	str_mask
					local	str_item = tbl_list_items[ii_li].Text
					if	tbl_volatiles
					then	for ii, ii_mask in ipairs(tbl_volatiles)
						do	local res_comp_name = far.ProcessName(PN_CMPNAMELIST, ii_mask, str_item)
							local res_str_match = string.match(str_item, ii_mask)
							if	res_comp_name
							or	res_str_match
							then	str_mask = ii_mask
								break
							end
						end
					end
					crc64_t:fnc_append(str_mask or str_item.."\n")
				end
			elseif	dei[10] --[[ = Адрес текстовой строки,
			которая будет использоваться как внутреннее название истории редактирования (см. также флаг DIF_HISTORY)]]
			and	dei[1] ~= 4
			and	dei[1] ~= 5
			and	dei[1] ~= 6
			then
			
				crc64_t:fnc_append(dei[10].."\n")
			end
		end
	end
	local t_crc_2 = Far.UpTime
	if 	sender == "event"
	and	msg == DN_INITDIALOG
	then
		for n in pairs(_dlg_info) do table.insert(dlg_info_sign, n) end
		table.sort(dlg_info_sign)
		dlg_type_sign = "{"..table.concat(dlg_info_sign, "&").."}"
		local	is_menu_likely, is_dlg_likely
		if	dlg_elems[1][1] == 11 and #dlg_elems == 1
		then	dlg_titles = _hDlg:send(DM_LISTGETTITLES, 1)
			is_menu_likely = (dlg_titles or dlg_is_menu == "M") and true
		end
		if not	is_menu_likely
		then	local	str_title = _hDlg:send(DM_GETDIALOGTITLE, -1)
			if	str_title
			then	is_dlg_likely = true
				dlg_titles = { Title = str_title }
			else	error("how is it possible !?!?!?!?")
			end
		end
		if	Area.Current	== "MainMenu" and is_menu_likely
		then	guess_area	=  "MainMenu";	  is_menu = true
		elseif 	dlg_type_sign	== "{Flags&Id&Name&Pos&Type&TypeName}" and
			is_menu_likely and (
				Area.Current	== "UserMenu" or
				_last_key	== "F2" or
				_last_key:match("Enter") and Area.Current == "UserMenu" or
				_last_area	== "UserMenu"
					)
		then	guess_area	=  "UserMenu"	; is_menu = true
		elseif  is_menu_likely and
			dlg_titles and (
				string.match(dlg_titles.Title, "^Change drive") and
				string.match(dlg_titles.Bottom, "^Del Shift+Del F3 F4 F9$")
				or _dlg_handles[dlg_hnd_str].mcr_area == "Disks"
					)
		then	guess_area	=  "DiskMenu"	; is_menu = true
		elseif	is_menu_likely and
			(dlg_type_sign	== "{Flags&Id&Name&Pos&Type&TypeName}" or dlg_guid)
		then	guess_area	=  "Menu"	; is_menu = true
		else	guess_area	=  "Dialog"	; is_menu = false
		end
		if	dlg_titles
		then	if	dlg_titles.Bottom
			then	local	F5_beg, F5_end, F5_L, F5_str, F5_R = dlg_titles.Bottom:find("([,\\/[ ]+)("..ACT_KEY_F5..")([,\\/: ]+)")
				if	F5_beg
				then	local bottom_new =
						string.format("%s%sAlt%s%s%s",
						string.sub(dlg_titles.Bottom, 1, F5_beg - 1),
						F5_L, ACT_KEY_F5, F5_R,
						string.sub(dlg_titles.Bottom, F5_end + 1)
							)
					_hDlg:send(DM_LISTSETTITLES, 1, { Title = dlg_titles.Title, Bottom = bottom_new } )
					_has_own_F5 = true
				end
			end
			if not	is_safe_id and is_menu
			then	if dlg_titles.Title	then crc64_t:fnc_append("[HEADER:] "..dlg_titles.Title)	end
				if dlg_titles.Bottom	then crc64_t:fnc_append("[FOOTER:] "..dlg_titles.Bottom)	end
			end
		end
		dlg_sign =
			dlg_is_menu.."*"..dlg_type_sign.."*"..guess_area.."$"..
			(
				is_menu
				and	("[%sT\\%sB]\n"):format(
					dlg_titles and dlg_titles.Title	 and "L" or "m",
					dlg_titles and dlg_titles.Bottom and "P" or "q"
						)
				or	("[w:%X+h:%X+t:%s]\n"):format(
					dlg_width,
					dlg_height,
					dlg_titles and dlg_titles.Title and "t" or "n"
						)
			)
		for	deii = 1, #dlg_elszs, 1
		do	dei = { Ty = dlg_elszs[deii][1],
				X1 = dlg_elszs[deii][2],
				Y1 = dlg_elszs[deii][3],
				X2 = dlg_elszs[deii][4],
				Y2 = dlg_elszs[deii][5],
				Tx = dlg_elszs[deii][6]}
			dlg_sign = dlg_sign..("I#%x,K:%s,L:%s,T:%x,R:%s,B:%x,W:%s\n"):format(deii, CTLs[dei.Ty]:lower(),
				(dei.X1 < 0 and "-%X" or "%x"):format(math.abs(dei.X1)),
				(dei.Y1),
				(dei.X2 < 0 and "-%X" or "%x"):format(is_menu and 987 or math.abs(dei.X2)),
				is_menu and 248 or dei.Y2,
				dei.Tx and "Y" or "N")
			deo = { }
			for	dejj = 1, #dlg_elszs, 1
			do	if dejj ~= deii and band(dlg_elszs[dejj][9], DIF_HIDDEN) == 0 then
				dej = { Ty = dlg_elszs[deii][1],
					X1 = dlg_elszs[dejj][2],
					Y1 = dlg_elszs[dejj][3],
					X2 = dlg_elszs[dejj][4],
					Y2 = dlg_elszs[dejj][5],
					Tx = dlg_elszs[dejj][6]}
				if	dej.X1 >= dei.X2 and (
					dej.Y1 >= dei.Y1 and dej.Y1 <= dei.Y2 or
				 	dej.Y2 >= dei.Y1 and dej.Y2 <= dei.Y2 or
				 	dej.Y1 <= dei.Y1 and dej.Y2 >= dei.Y2)
				then	deo[dejj] = { X = dej.X1, B = dej.X1 == dei.X2, T = "X1", D = dej.X1 - dei.X2 }
				elseif	dej.X2 >= dei.X2 and
					dej.X1 <  dei.X1 and (
					dej.Y1 >= dei.Y1 and dej.Y1 <= dei.Y2 or
				 	dej.Y2 >= dei.Y1 and dej.Y2 <= dei.Y2 or
				 	dej.Y1 <= dei.Y1 and dej.Y2 >= dei.Y2)
				then	deo[dejj] = {X = dej.X2, B = dej.X2 == dei.X2, T = "X2", D = dej.X2 - dei.X2}
				end
				if deo[dejj] then dlg_sign = ("%sO:(E=%x/J=%s/G=%s/A=%s)\n"):format(dlg_sign, dejj, CTLs[dej.Ty]:lower(), deo[dejj].B and "N" or "M", deo[dejj].T == "X1" and "U" or "V") end
			end end
			if	#deo == 0 then
				deo[-1] = { X = dlg_width, B = false, T = "X2", D = dlg_width - dei.X2 + 0 };
				dlg_sign = ("%sO:(N)"):format(dlg_sign)
			end
			dlg_obsts[deii] = deo;
		end
		local	dlg_sign_crc64_int,
			dlg_sign_crc64_str
		if not	is_safe_id
		then	local crc64_res = is_menu and crc64_t or _crc64:new()
			crc64_res:fnc_append(dlg_sign)
			dlg_sign_crc64_int,
			dlg_sign_crc64_str =
				crc64_res:fnc_result(dlg_sign)
		end
		dlg_xuid =
			is_safe_id and dlg_guid..(dlg_afnLR and (dlg_afnLR > 0 and "$R" or "$L") or "")
			or dlg_guid and dlg_guid.."#"..dlg_sign_crc64_str
			or dlg_sign_crc64_str
		if not	is_safe_id
		and	dlg_guid_vlt
		then	local	tbl_id_stats = _dlg_id_stats[dlg_guid_vlt]
			if not 	tbl_id_stats
			then	tbl_id_stats = { named_id = tbl_far_guid_names[dlg_guid_vlt] }
				_dlg_id_stats[dlg_guid_vlt] = tbl_id_stats
			end
			tbl_id_stats[dlg_sign_crc64_str] = (tbl_id_stats[dlg_sign_crc64_str] or 0) + 1
		end
		if not	_dlg_data[dlg_xuid]
		then	_dlg_data[dlg_xuid] = {
				guid = dlg_guid,
				guid_vlt = dlg_guid_vlt and dlg_guid ~= dlg_guid_vlt and dlg_guid_vlt or nil,
				named_id = dlg_guid_vlt and tbl_far_guid_names[dlg_guid_vlt] or nil,
				xuid = dlg_xuid,
				crc64 = dlg_sign_crc64_str,
				area = guess_area,
				is_menu	= is_menu
					}
		end
		
		_dlg_data[dlg_xuid].crc_t	= t_crc_2 - t_crc_1
		_dlg_data[dlg_xuid].text_head	= dlg_titles and dlg_titles.Title
		_dlg_data[dlg_xuid].text_foot	= dlg_titles and dlg_titles.Bottom
		-- these dlg_obsts, gmtr, elems, affnt, +open time required only as initial for the dialog:
		_dlg_data[dlg_xuid].obstacles	= fnc_tbl_copy(dlg_obsts)
		_dlg_data[dlg_xuid].gmtr_orig	= fnc_tbl_copy(dlg_gmtr)
		_dlg_data[dlg_xuid].elms_orig	= fnc_tbl_copy(dlg_elems)
		_dlg_data[dlg_xuid].affnt_lr	= dlg_afnLR
		_dlg_data[dlg_xuid].dt_opened	= os.time()
		
		_dlg_handles[dlg_hnd_str].xuid = dlg_xuid
		_dlg_handles[dlg_hnd_str].named_id = _dlg_data[dlg_xuid].named_id
		_dlg_handles[dlg_hnd_str].dt_detect = Far.UpTime
		_dlg_handles[dlg_hnd_str].text_top = _dlg_data[dlg_xuid].text_head
		_dlg_handles[dlg_hnd_str].text_low = _dlg_data[dlg_xuid].text_foot
		if not	Xer0X.DLG_TRACK_OFF
		then
			if not	is_menu
			then
			end
			local	dlg_menu_list_item_idx_by_pos,
				dlg_menu_list_item_by_str, res_comp_name,
				menu_sel_res, menu_item_text_fix, is_masked
			local	menu_ret_pos_sel = _dlg_data[dlg_xuid].menu_pos_sel
			local	menu_ret_val_str = _dlg_data[dlg_xuid].menu_val_str
			local	menu_ret_disable = _dlg_exc_ret_ids[dlg_guid]
			if	is_menu
			and not	menu_ret_disable
			and	menu_ret_pos_sel
			then
				if	tbl_volatiles
				then	for ii, ii_mask in ipairs(tbl_volatiles)
					do	local res_comp_name = far.ProcessName(PN_CMPNAMELIST, ii_mask, menu_ret_val_str)
						local res_str_match = string.match(menu_ret_val_str, ii_mask)
						if	res_comp_name
						or	res_str_match
						then	menu_ret_val_str = ii_mask
							is_masked = true
							break
						end
					end
				end
			
				dlg_menu_list_idx_by_text = _hDlg:send("DM_LISTFINDSTRING", 1, { Pattern = menu_ret_val_str, Flags = { PN_CMPNAMELIST } })
				if not	dlg_menu_list_idx_by_text
				and	is_masked
				then	for ii, ii_val in ipairs(dlg_elems[1][6])
					do	local	res_comp_name = far.ProcessName(PN_CMPNAMELIST, menu_ret_val_str, ii_val.Text)
						local	res_str_match = string.match(ii_val.Text, menu_ret_val_str)
						if	res_comp_name
						or	res_str_match
						then	dlg_menu_list_idx_by_text = ii
							break
						end
					end
				end
				dlg_menu_list_item_by_pos = _hDlg:send("DM_LISTGETITEM", 1,
					dlg_menu_list_idx_by_text or menu_ret_pos_sel
						)
				if	dlg_menu_list_item_by_pos
				then
					menu_item_text_fix = fnc_norm_menu_value(dlg_menu_list_item_by_pos.Text)
					if	menu_item_text_fix == _dlg_data[dlg_xuid].menu_val_str
					or	is_masked and (
							far.ProcessName(PN_CMPNAMELIST, menu_ret_val_str, dlg_menu_list_item_by_pos.Text)
						or	far.ProcessName(PN_CMPNAMELIST, menu_ret_val_str, menu_item_text_fix)
						or	string.match(dlg_menu_list_item_by_pos.Text, menu_ret_val_str)
						or	string.match(menu_item_text_fix, menu_ret_val_str)
							)
					then	menu_sel_res = _hDlg:send("DM_LISTSETCURPOS", 1, {
							SelectPos= dlg_menu_list_idx_by_text or menu_ret_pos_sel,
							})
					end
				end
			end
			if _dlg_data[dlg_xuid].widmod
			then    tbl_layout_operations[#tbl_layout_operations + 1] = {
					op_key = ACT_KEY_F5,
					the_mod = tbl_widmod_types[_dlg_data[dlg_xuid].widmod]
						}
			end
			if _dlg_data[dlg_xuid].posmod
			then
				local	the_mod
				local	pos_mod_data = _dlg_data[dlg_xuid].posmod
				local 	pos_mod_data_type = type(pos_mod_data)
				local 	pos_mod_str, pos_mod_key
				if	pos_mod_data_type == "number"
				then 	pos_mod_str = tbl_posmod_types[pos_mod_data]
					pos_mod_key = tbl_posmod_keys[pos_mod_str]
				elseif	pos_mod_data_type == "table"
				then
					pos_mod_key = "CtrlAltF123"
					the_mod = pos_mod_data
				end
				tbl_layout_operations[#tbl_layout_operations + 1] = {
					op_key = pos_mod_key, the_mod = the_mod
				}
			end
		end -- of "IF Track Allowed .."
	elseif
		sender == "macro"
	then
		if not	Xer0X.DLG_TRACK_OFF
		then
			dlg_xuid = _dlg_handles[dlg_hnd_str].xuid
			if
				msg == "CtrlAltR"
			then
				_dlg_data[dlg_xuid].pers = true
			else
				--[[ created and saved in event,
				but for key macro need to fetch it from storage:]]
				dlg_obsts = _dlg_data[dlg_xuid].obstacles
				tbl_layout_operations[#tbl_layout_operations + 1] = {
					op_key = msg,
					the_mod = msg == ACT_KEY_F5 and
						fnc_widmod_state_machine(tbl_widmod_types[_dlg_data[dlg_xuid].widmod], _dlg_data[dlg_xuid].wid_cust)
							or nil
					}
			end
		end
	end
	::fix_alignment::
	local wid_adj_loop = false
	for ii_op = 1, #tbl_layout_operations do
		local op_cmd, dlg_crd = fnc_calc_move(
			tbl_layout_operations[ii_op].op_key,
			tbl_layout_operations[ii_op].the_mod,
			-- initial saved:
			_dlg_data[dlg_xuid].affnt_lr,
			dlg_gmtr,
			_dlg_data[dlg_xuid].gmtr_orig,
			_dlg_data[dlg_xuid].wid_cust
				)
		local	dlg_place_tmp, dlg_size_tmp = fnc_layout_cmd_exec(op_cmd, dlg_gmtr)
		dlg_gmtr = fnc_gmtr_calc(dlg_gmtr, dlg_place_tmp, dlg_size_tmp)
		local	wid_mod_id = dlg_size_tmp  and tbl_widmod_ids[op_cmd.op_code]
		local	pos_mod_id = dlg_place_tmp and tbl_posmod_ids[op_cmd.op_code]
		if	wid_mod_id then
			_dlg_data[dlg_xuid].widmod = wid_mod_id
			if op_cmd.op_code == "WidthCustom" then
				_dlg_data[dlg_xuid].wid_cust = dlg_size_tmp.X
			end
			wid_adj_loop = true
			wid_adj = true
		end
		if	pos_mod_id then
			_dlg_data[dlg_xuid].posmod = op_cmd.aligned and (op_cmd.algn_id or pos_mod_id) or dlg_place_tmp
		end
	end
	if wid_adj_loop and tbl_aligned[_dlg_data[dlg_xuid].posmod]
	then
		local dlg_gmtr_test = dlg_coord.fnc_prep(nil, dlg_gmtr)
		if dlg_gmtr_test.align_id ~= _dlg_data[dlg_xuid].posmod then
			tbl_layout_operations = {{op_key = tbl_posmod_keys[_dlg_data[dlg_xuid].posmod]}}
			goto fix_alignment
		end
	end
	-- was width change
	if wid_adj then
	--[[ always current required,
	probably table copy is not needed:]]
	_dlg_data[dlg_xuid].gmtr_curr	= dlg_gmtr
	_dlg_data[dlg_xuid].elm_sizes	= dlg_elszs
	_dlg_data[dlg_xuid].elms_curr	= dlg_elems
	targ_W = dlg_gmtr.W
	local total_height = 0
	for	deii, _dei in pairs(dlg_elszs)
	do	dei = { _dei[1], _dei[2], _dei[3], _dei[4], _dei[5], _dei[6], _dei[7], _dei[8], _dei[9], _dei[10] }
		local elm_lim, elm_mod, elem_orig_x2, elem_targ_x2 = nil, false, dei[4], -1
		total_height = math.max(math.max(total_height, dei[5]), dei[3])
		-- menu with zero width:
		if	dei[1] == 11
		and	dei[2] == 0
		and	dei[3] == 0
		and	dei[4] == 0
		then	dei[4] = 1
		end
		if	rest_orig
		then	if	elem_orig_x2 ~= dlg_elszs[deii][4]
			then	elem_targ_x2  = dlg_elszs[deii][4]
				elm_mod = true
			end
		elseif	dei[2] ~= -1 and band(dei[9], DIF_HIDDEN) == 0
		then
			local elm_min_x2 = dei[2]
				+ mf.iif(dei[1] == DI_FIXEDIT,
					string.len(fnc_trim_R(dei[10])),
						0)
				+ mf.iif(dei[1] == DI_TEXT,
					string.len(fnc_trim_R(dei[10])),
						0)
			local has_width, is_inside_1, is_inside_2, is_border_1, is_border_2, elm_lim, elm_lim_idx
			for elm_new_x2 = elm_min_x2, targ_W - 1, 1 do
				dei[4] = elm_new_x2
				has_width, is_inside_1, is_inside_2, is_border_1, is_border_2, elm_lim, elm_lim_idx = fnc_dlg_elm_vs_all(dlg_elszs, dlg_obsts[deii], dei, deii, 1)
				if 	elm_lim
				then	elm_mod = true
					elem_targ_x2 = math.min(targ_W, dei[4]) - 1
					break
				end
			end
			if not	elm_lim and dlg_obsts[deii][-1]
			then	elm_mod = true
				elem_targ_x2 = targ_W - dlg_obsts[deii][-1].D
			end
		end
		if	dei[1] == 0 and
			dei[10]:len() > 0
		then	local 	max_size = (elm_lim and dlg_elems[elm_lim_idx][4] or targ_W) - dei[2] - 3
			local 	str_orig =
					fnc_trim_R(_dlg_data[dlg_xuid].elms_orig[deii][10])
			local 	str_rest = fnc_rest_long_file_name(str_orig, max_size)
			if	str_rest
			then	far.SendDlgMessage(_hDlg, DM_SETTEXT, deii, str_rest)
				
				dei[10] = str_rest
				dlg_elems[deii][10] = str_rest
				elem_targ_x2 = 0
				elm_mod = true
			end
		end
		if	elm_mod
		then
		
			if pcall(function()
				local ret_val
				
				dlg_elszs[deii][4] = elem_targ_x2
				dlg_elems[deii][4] = elem_targ_x2
				local str_trimd = fnc_trim_R(dei[10])
				if	dei[01] == 0
				and	dei[10]:len() > elem_targ_x2 - dei[2] + 1
				and
					dei[10]:len() >
						string.len(str_trimd)
				then 	dlg_elems[deii][10] =
						str_trimd
				end
				ret_val = far.SetDlgItem(_hDlg, deii, dlg_elems[deii])
			end) then end -- of PCall(SetDlgItem)
		end -- of element modified
	end end

end


local function fnc_get_mcr_area_info(hDlg, src)
	local	dt_now = Far.UpTime
	local 	dlg_hnd_str = tostring(hDlg)
	local	dlg_handle = _dlg_handles[dlg_hnd_str]
	local	mcr_inf_win = far.AdvControl("ACTL_GETWINDOWINFO")
	dlg_handle.mcr_area = Area.Current
	dlg_handle.mcr_relaunch =
		type(mcr_inf_win.Id) ~= "userdata" or
		tostring(mcr_inf_win.Id) ~= dlg_hnd_str
	if	dlg_handle.mcr_relaunch
	then	return
	end
	if	dlg_handle.is_closing
	or	dlg_handle.is_closed
	then	dlg_handle.mcr_closing = dt_now
		return
	end
	dlg_handle.mcr_inf_win = mcr_inf_win
	dlg_handle.mcr_inf_dlg = far.SendDlgMessage(hDlg, "DM_GETDIALOGINFO")
	if dlg_handle.dt_mcr and dlg_handle.dt_mcr == dt_now then return end
	dlg_handle.mcr_guid =
		tbl_menu_areas[Area.Current]
			and Menu.Id	~= "" and Menu.Id	~= GUID_ZERO	and Menu.Id	and Menu.Id
		or Area.Dialog
			and Dlg.Id	~= "" and Dlg.Id	~= GUID_ZERO	and Dlg.Id	and Dlg.Id
	dlg_handle.mcr_guid_owner = Dlg.Owner
	dlg_handle.dt_mcr = dt_now
end

local fnc_event_async_safe

local function fnc_event_async_safe__resume(tmr_sender, is_sender_active, dlg_handle, evt, fde)
	if	is_sender_active
	then	tmr_sender.Enabled = true
	else	tmr_sender = far.Timer(15, fnc_event_async_safe, evt, fde)
		dlg_handle.tmr_init = tmr_sender
	end
	return	tmr_sender
end

local function fnc_event_async_safe__close(tmr_sender, is_sender_active, str_note)
	if is_sender_active then tmr_sender:Close() end
	return tmr_sender
end

local _dt_tmr_dlg_wait_prev
fnc_event_async_safe = function(tmr_sender, evt, fde)
-- ###
local	dt_now = Far.UpTime
local	is_sender_active = tmr_sender and not tmr_sender.Closed and tmr_sender.Interval and tmr_sender.Enabled
local	dt_call_delta = is_sender_active and (dt_now - (_dt_tmr_dlg_wait_prev or 0)) or -1
if	is_sender_active
then	if	dt_call_delta == 0
	then	return tmr_sender
	else 	_dt_tmr_dlg_wait_prev = dt_now
		tmr_sender.Enabled = false
	end
end
local	dlg_hnd_str = tostring(fde.hDlg)
local	dlg_handle = _dlg_handles[dlg_hnd_str]
if	dlg_handle.is_closing
or	dlg_handle.is_closed
then	return fnc_event_async_safe__close(tmr_sender, is_sender_active, nil)
end
local mcr_read=(dlg_handle.dt_mcr	or	0) > dlg_handle.dt_init
local mcr_retr=(dlg_handle.dt_mcr_launch or	0) < math.max(dt_now - 100, dlg_handle.dt_init)
		and not mcr_read
local dlg_inf_w =
	(	dlg_handle.dlg_inf_win_dt or	0) > dlg_handle.dt_init
	and	dlg_handle.dlg_inf_win
	or	far.AdvControl(ACTL_GETWINDOWINFO)
if	dlg_hnd_str ~= tostring(dlg_inf_w and dlg_inf_w.Id)
then	if	mcr_read
	then	dlg_inf_w = dlg_handle.mcr_inf_win
	elseif (dlg_handle.mcr_cnt_no_wnd or	0) > 3
	then	return fnc_event_async_safe__close(tmr_sender, is_sender_active, "BAD WINDOW!!!")
	else	dlg_handle.dt_mcr_launch = dt_now
		dlg_handle.mcr_cnt_no_wnd = (dlg_handle.mcr_cnt_no_wnd or 0) + 1
		dlg_handle.mcr_post = mf.postmacro(fnc_get_mcr_area_info, fde.hDlg, "check_wnd")
		return fnc_event_async_safe__resume(tmr_sender, is_sender_active, dlg_handle, evt, fde)
	end
else    dlg_handle.dlg_inf_win = dlg_inf_w
	dlg_handle.dlg_inf_win_dt = dt_now
end
local	dlg_inf_d, check_dlg
if	mcr_read
then	dlg_inf_d = dlg_handle.mcr_inf_dlg
else	if	mcr_retr
	or not	dlg_handle.dlg_infos_cnt
	then	dlg_inf_d = far.SendDlgMessage(fde.hDlg, DM_GETDIALOGINFO)
		if	dlg_inf_d
		then	if not	dlg_handle.dlg_infos[dlg_inf_d.Id]
			then	dlg_handle.dlg_infos[dlg_inf_d.Id] = dlg_inf_d
				dlg_handle.dlg_infos_cnt= (dlg_handle.dlg_infos_cnt or 0) + 1
			end
			dlg_handle.dlg_infos_dt = (dlg_handle.dlg_infos_dt or dt_now)
		else	dlg_handle.dlg_infos_cnt= 0
		end
	end
	if	(dlg_handle.mcr_cnt_ch_dlg or 0) < 4
	then	if	mcr_retr
		then	dlg_handle.dt_mcr_launch = dt_now
			dlg_handle.mcr_cnt_ch_dlg = (dlg_handle.mcr_cnt_ch_dlg or 0) + 1
			dlg_handle.mcr_post = mf.postmacro(fnc_get_mcr_area_info, fde.hDlg, "check_dlg")
		end
		return fnc_event_async_safe__resume(tmr_sender, is_sender_active, dlg_handle, evt, fde)
	end
end
fnc_event_async_safe__close(tmr_sender, is_sender_active)
local dlg_is_menu = (not dlg_inf_d or tbl_menu_areas[dlg_handle.mcr_area]) and "M" or "D"
local dlg_guid = dlg_inf_d and fnc_norm_guid(dlg_inf_d.Id) or fnc_norm_guid(Dlg.Id) or fnc_norm_guid(Menu.Id) or fnc_norm_guid(dlg_handle.mcr_guid)
local dlg_guid_own = dlg_inf_d and fnc_norm_guid(dlg_inf_d.Owner) or fnc_norm_guid(Dlg.Owner) or fnc_norm_guid(dlg_handle.mcr_guid_owner)
--[[ -- drop down box for free text:
if	false
--!	or dlg_guid == "4406C688-209F-4378-8B7B-465BF16205FF"
--!	or dlg_guid == "D853E243-6B82-4B84-96CD-E733D77EEAA1"
then return false end
]]
_dlg_guid		= dlg_guid
_dlg_guid_evt		= dlg_guid
_dlg_guid_own_evt	= dlg_guid_own
_dlg_guid_own		= dlg_guid_own
_dlg_info_evt		= dlg_inf_d or dlg_inf_w
_dlg_info		= dlg_inf_d or dlg_inf_w
_evt			= evt
_fde			= fde
_hDlg_evt		= fde.hDlg
_hDlg			= fde.hDlg


fnc_action("event", fde.Msg, dlg_is_menu)
return tmr_sender

-- @@@ end of fnc_event_async_safe
end

local function fnc_close_countdown(tmr_sender, dlg_hnd_str, dt_closing, force_close)
	tmr_sender.Enabled = false
	tmr_sender:Close()
	local dlg_hand = _dlg_handles[dlg_hnd_str]
	if	force_close
	or	dlg_hand.dt_updated == dt_closing
	or	dlg_hand.evt_updated.fde.Msg == DN_CLOSE
	then	dlg_hand.is_opened = false
		dlg_hand.is_closed = true
		dlg_hand.dt_closed = dt_closing
	else	dlg_hand.CLOSE_CANCEL = Far.UpTime
	end;
	dlg_hand.is_closing = false
end

Event { description = "[ReXiZeR] ultra total dialog and menu windows resizer";
	group = "DialogEvent";
	action = function(evt, fde)
-- ###
local	dt_now = Far.UpTime
local	dlg_data
local	dlg_draw  = evt == DE_DLGPROCINIT and fde.Msg == DN_DRAWDIALOGDONE
local	dlg_init  = evt == DE_DLGPROCINIT and fde.Msg == DN_INITDIALOG
local	dlg_close = evt == DE_DLGPROCINIT and fde.Msg == DN_CLOSE
local	dlg_hnd_str = tostring(fde.hDlg)
local	dlg_hand = _dlg_handles[dlg_hnd_str]
if	dlg_hand
and	dlg_hand.is_closing
and (	dlg_hand.is_closed or dlg_init)
then	fnc_close_countdown(dlg_hand.tmr_close_countdown, dlg_hnd_str, dt_now, true)
elseif
not	dlg_hand
then	dlg_hand = { handle_str = dlg_hnd_str, hanlde = fde.hDlg, dt_init = dt_now }
	_dlg_handles[dlg_hnd_str] = dlg_hand
end
if	dlg_init
then
	dlg_hand.dt_init	= dt_now
	dlg_hand.evt_cnt	= 0
	dlg_hand.dlg_infos	= {}
	dlg_hand.dlg_infos_cnt	= nil
	dlg_hand.dlg_infos_dt	= nil
	dlg_hand.mcr_cnt_ch_dlg = 0
	dlg_hand.mcr_cnt_no_wnd = 0
	dlg_hand.dt_mcr		= 0
	dlg_hand.dt_mcr_launch	= 0
	dlg_hand.mcr_relaunch = false
	dlg_hand.dlg_inf_bak = nil
	dlg_hand.mcr_inf_win = nil
	dlg_hand.mcr_inf_dlg = nil
	dlg_hand.is_closing = false
	dlg_hand.is_closed = false
end
dlg_hand.dt_updated = dt_now
dlg_hand.evt_updated = { evt = evt, fde = fde }
if
	evt == DE_DLGPROCINIT and (
		fde.Msg == DN_INPUT or
		fde.Msg == DN_CONTROLINPUT
			)
then	dlg_hand.evt_cnt = (dlg_hand.evt_cnt or 0) + 1
end
if	fde.Msg ~= DN_ENTERIDLE
and	fde.Msg ~= DN_INPUT
and	fde.Msg ~= DN_CONTROLINPUT
and	fde.Msg ~= DN_GOTFOCUS
and	fde.Msg ~= DN_KILLFOCUS
then
end

if 	dlg_hand.xuid
then	dlg_data = _dlg_data[dlg_hand.xuid]
end


if
	dlg_close
then
	if not	Xer0X.DLG_TRACK_OFF
	and	dlg_data
	and	dlg_data.is_menu
	and not _dlg_exc_ret_ids[dlg_data.guid]
	then	if 	dlg_data.guid == Menu.Id or (
			dlg_data.guid == nil and (
				Area.Current == "MainMenu" or
				Area.Current == "UserMenu"
					) and
			Menu.Id == GUID_ZERO
				)
		then    local	tbl_menu_sel = fde.hDlg:send("DM_LISTGETCURPOS", 1)
			if	tbl_menu_sel.SelectPos == 1
			and	false
			then
			else
				dlg_data.menu_pos_sel = tbl_menu_sel.SelectPos
				dlg_data.menu_pos_top = tbl_menu_sel.TopPos
				dlg_data.menu_val_str =
					dlg_data.menu_vals_map and
					dlg_data.menu_vals_map.new_to_val[Menu.Value]
						or Menu.Value
			end
		end
	end
	if	dlg_hand.xuid == FAR_EXIT_MSG_DLG_ID_TXT
	then	fnc_dlg_data_store()
	end
	if not	dlg_hand.is_closing
	then
		dlg_hand.is_closing = true
		dlg_hand.dt_closing = dt_now
		dlg_hand.tmr_close_countdown = far.Timer(5, fnc_close_countdown, dlg_hnd_str, dt_now)
	end
elseif
	dlg_init
then
	if not	dlg_hand.tmr_init
	or	dlg_hand.tmr_init.Closed
	then	dlg_hand.tmr_init = fnc_event_async_safe(dlg_hand.tmr_init, evt, fde)
	end
end
-- @@@ END OF DialogEvent FUNCTION
	end
}

local function fnc_macro_prep_work()
	local the_key = akey(1, 0)
		:gsub("RAlt",	"Alt")
		:gsub("RCtrl",	"Ctrl")
	local dlg_guid		= fnc_norm_guid(Area.Dialog and Dlg.Id or Menu.Id)
	local dlg_guid_own	= fnc_norm_guid(Area.Dialog and Dlg.Owner)
	if false
	-- drop down box for free text:
	-- or dlg_guid == "4406C688-209F-4378-8B7B-465BF16205FF"
	-- or dlg_guid == "D853E243-6B82-4B84-96CD-E733D77EEAA1"
	then return false
	end
	local dlg_info = far.AdvControl(ACTL_GETWINDOWINFO, nil)
	if dlg_info.Id == 0 then return; end
	_hDlg_mcr		= dlg_info.Id
	_hDlg			= dlg_info.Id
	_dlg_info_mcr		= dlg_info
	_dlg_info		= dlg_info
	_dlg_guid_mcr		= dlg_guid
	_dlg_guid		= dlg_guid
	_dlg_guid_own_mcr	= dlg_guid_own
	_dlg_guid_own		= dlg_guid
	return true, the_key
end

local str_title = "[ReXiZeR] Resize dialogs && other sub-windows @Xer0X"
local str_areas_of_interest = string.lower("Other Dialog MainMenu Menu UserMenu Disks Search ShellAutoCompletion")
Macro { description = str_title;
	id = "B4536879-7071-4619-8F9C-6DBE59E3B6E2";
	area = str_areas_of_interest;
	priority = 0; sortpriority = 0;
	condition = function(the_key, sender)
-- ###
return not the_key:find("Alt"..ACT_KEY_F5) or _has_own_F5;
-- @@@
	end;
--	key = "/(.Ctrl)?(.Alt(Right|Left|Up|Down))|(F2)/";
	key = ACT_KEYS_ALL;
	action = function(sender)
-- ###
local ok, the_key = fnc_macro_prep_work()
if not ok then return end
if	the_key:find("Alt"..ACT_KEY_F5)
then	if _has_own_F5 then Keys(ACT_KEY_F5) end
	return
end
fnc_action("macro", the_key)
do --[[ this block required for correct redrawing of some dialogs,
	for example search results dialog ]]
	Panel.SetPosIdx(0, APanel.CurPos)
	Panel.SetPosIdx(1, PPanel.CurPos)
	far.AdvControl("ACTL_REDRAWALL")
end
-- @@@ macro action
	end;
}

Macro { description = string.gsub(str_title, " Resize ", " Persist ");
	area = "Common"; 
	key = "CtrlAltR-R";
	action = function(sender)
-- ###
fnc_dlg_data_store()
-- @@@ macro action
	end;
}

local stop_me = false;

Macro {	description	= "[ReXiZeR] just record the last pressed key";
	area		= "Common";
	key		= "/(.|\n)*?/";
	priority	= 100;
	sortpriority	= 100;
	condition	= function(key)
-- ###
if	Menu.Id ~= "165AA6E3-C89B-4F82-A0C5-C309243FD21B"
then	_last_key = key;
	_last_area = Area.Current
end
return false
-- @@@
end;
	action = function() end;
}

local function fnc_cfg_dlg_exec(cfg_data, from_area)
	local dlg = far2dlg.NewDialog()
	dlg.dbxFrame		= { "DI_DOUBLEBOX",3, 1,42, 8, 0, 0, 0, 0,						lng_msg.MPluginSettings }
	dlg.ReloadDefaultScript = { "DI_CHECKBOX", 6, 2, 0, 0, 0, 0, 0, 0,						lng_msg.MReloadDefaultScript }
	dlg.RequireWithReload	= { "DI_CHECKBOX", 6, 3, 0, 0, 0, 0, 0, 0,						lng_msg.MRequireWithReload }
	dlg.UseStrict		= { "DI_CHECKBOX", 6, 4, 0, 0, 0, 0, 0, 0,						lng_msg.MUseStrict }
	dlg.ReturnToMainMenu	= { "DI_CHECKBOX", 6, 5, 0, 0, 0, 0, 0, 0,						lng_msg.MReturnToMainMenu }
	dlg.sep			= { "DI_TEXT",     0, 6, 0, 0, 0, 0, 0, { DIF_BOXCOLOR	= 1,	DIF_SEPARATOR	= 1 },	"" }
	dlg.btnOk		= { "DI_BUTTON",   0, 7, 0, 0, 0, 0, 0, { DIF_CENTERGROUP= 1,	DIF_DEFAULTBUTTON=1 },	lng_msg.MOk }
	dlg.btnCancel		= { "DI_BUTTON",   0, 7, 0, 0, 0, 0, 0, "DIF_CENTERGROUP",				lng_msg.MCancel }
	far2dlg.LoadData(dlg, cfg_data)
	local ret = far.Dialog(dlg_cfg_id, -1, -1, 46, 10, "PluginConfig", dlg)
	if ret == dlg.btnOk.id
	then	far2dlg.SaveData(dlg, cfg_data)
		return true
	end
end

MenuItem {
	description = str_title.." (menu item)";
	menu	= "Plugins Config";
	guid	= "01D17E94-FB83-41EC-AF01-8721539AFDAA";
	area	= "Dialog MainMenu Menu UserMenu Disks";
	text	= function(menu, area, p3) return str_title..(menu == "Config" and " (Config)" or "") end;
	action	= function(open_from, item, p3)
		if not	open_from
		then	local	is_saved = fnc_cfg_dlg_exec(cfg_current, "config")
			if	is_saved
			then	hist_data:save()
			end
		end
	end
}

NoEvent { description = "FAR exit detection (for ReXiZeR)";
--	group = "DialogEvent";
	action = function(evt, fde)
-- ###
if	evt	== DE_DLGPROCINIT
and	fde.Msg == DN_INITDIALOG
then	local	dlg_info = fde.hDlg:send(DM_GETDIALOGINFO)
	if	dlg_info and win.Uuid(dlg_info.Id):upper() == FAR_EXIT_MSG_DLG_ID_TXT
	then	fnc_dlg_data_store()
	end
end
-- @@@
	end;
}
-- @@@@@
