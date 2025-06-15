--Wiccanthrope Reason
local s,id,o=GetID()
function s.initial_effect(c)
	-- Xyz Summon from Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,1})
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- Add "Wiccanthrope" Spell when banished
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,2})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

function s.filter(c,e)
	return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end

function s.xyzfilter(c,mg,tp)
	return c:IsSetCard(0xf11) and c:IsXyzSummonable(nil,mg,1,2) and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local mg = Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil,e)

	if chk==0 then
		for tc in mg:Iter() do
			local g1 = Group.FromCards(tc)
			if s.validGroup(g1,tp) then
				return true
			end
			for tc2 in mg:Iter() do
				if tc ~= tc2 then
					local g2 = Group.FromCards(tc, tc2)
					if s.validGroup(g2,tp) then
						return true
					end
				end
			end
		end
		return false
	end

	-- Build selectable list (either valid alone or with at least one valid pair)
	local selectable = Group.CreateGroup()
	for tc in mg:Iter() do
		local g1 = Group.FromCards(tc)
		if s.validGroup(g1,tp) then
			selectable:AddCard(tc)
		else
			for other in mg:Iter() do
				if tc ~= other then
					local g2 = Group.FromCards(tc, other)
					if s.validGroup(g2,tp) then
						selectable:AddCard(tc)
						break
					end
				end
			end
		end
	end

	if #selectable == 0 then return false end -- fail-safe

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local firstGroup = selectable:Select(tp,1,1,nil)
	if not firstGroup or #firstGroup == 0 then return end

	local first = firstGroup:GetFirst()
	local g1 = Group.FromCards(first)

	if s.validGroup(g1,tp) then
		-- Valid solo — resolve
		Duel.SetTargetCard(g1)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
		return
	end

	-- Not valid solo — must pick a valid partner
	local validSeconds = Group.CreateGroup()
	for tc in mg:Iter() do
		if tc ~= first then
			local pair = Group.FromCards(first, tc)
			if s.validGroup(pair, tp) then
				validSeconds:AddCard(tc)
			end
		end
	end

	if #validSeconds == 0 then return end -- no valid 2nd, shouldn't happen

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local secondGroup = validSeconds:Select(tp,1,1,nil)
	if not secondGroup or #secondGroup == 0 then return end

	local finalGroup = Group.FromCards(first)
	finalGroup:Merge(secondGroup)

	Duel.SetTargetCard(finalGroup)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end



function s.getSelectableGroup(mg, tp)
	local res = Group.CreateGroup()
	local seen = {}

	local mgList = {}
	local tc = mg:GetFirst()
	while tc do
		table.insert(mgList, tc)
		tc = mg:GetNext()
	end

	for i = 1, #mgList do
		local c1 = mgList[i]
		local g1 = Group.FromCards(c1)
		if s.validGroup(g1, tp) then
			res:Merge(g1)
		end

		for j = i + 1, #mgList do
			local c2 = mgList[j]
			local g2 = Group.FromCards(c1, c2)
			if s.validGroup(g2, tp) then
				res:Merge(g2)
			end
		end
	end

	return res
end


function s.hasValidSubgroup(mg, tp)
	local mgList = {}
	local tc = mg:GetFirst()
	while tc do
		table.insert(mgList, tc)
		tc = mg:GetNext()
	end

	for i = 1, #mgList do
		local c1 = mgList[i]
		local g1 = Group.FromCards(c1)
		if s.validGroup(g1, tp) then return true end

		for j = i + 1, #mgList do
			local c2 = mgList[j]
			local g2 = Group.FromCards(c1, c2)
			if s.validGroup(g2, tp) then return true end
		end
	end
	return false
end

function s.getValidGroups(mg,tp)
	local res = Group.CreateGroup()
	local tab = {}
	local mgList = {}
	local tc = mg:GetFirst()
	while tc do
		table.insert(mgList, tc)
		tc = mg:GetNext()
	end

	for i = 1, #mgList do
		local c1 = mgList[i]
		local g1 = Group.FromCards(c1)
		if Duel.IsExistingMatchingCard(s.xyzfilter, tp, LOCATION_EXTRA, 0, 1, nil, g1, tp) then
			g1:KeepAlive()
			res:Merge(g1)
		end
		for j = i + 1, #mgList do
			local c2 = mgList[j]
			local g2 = Group.FromCards(c1, c2)
			if Duel.IsExistingMatchingCard(s.xyzfilter, tp, LOCATION_EXTRA, 0, 1, nil, g2, tp) then
				g2:KeepAlive()
				res:Merge(g2)
			end
		end
	end

	return res
end

-- Returns TRUE if g (size 1‑2) can be used to Xyz‑Summon a Wiccanthrope monster
function s.validGroup(g,tp)
	local n=#g
	if n==1 then
		local c=g:GetFirst()
		-- single target = only a Rank 4‑or‑lower Wiccanthrope Xyz (for Stormgnarl)
		return c:IsType(TYPE_XYZ) and c:IsSetCard(0xf11) and c:GetRank()<=4
			and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,g,tp)
	elseif n==2 then
		-- you cannot mix any Xyz with another monster
		for tc in aux.Next(g) do if tc:IsType(TYPE_XYZ) then return false end end
		-- duo must be able to summon a Wiccanthrope Xyz
		return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,g,tp)
	end
	return false
end

function s.hasValidTarget(mg, tp)
	local tcList = {}
	local tc = mg:GetFirst()
	while tc do
		table.insert(tcList, tc)
		tc = mg:GetNext()
	end
	-- check single-card (rank 4 Wiccanthrope Xyz)
	for i = 1, #tcList do
		local g1 = Group.FromCards(tcList[i])
		if s.validGroup(g1, tp) then return true end
	end
	-- check 2-card pairs (must be valid for Wiccanthrope Xyz)
	for i = 1, #tcList do
		for j = i+1, #tcList do
			local g2 = Group.FromCards(tcList[i], tcList[j])
			if s.validGroup(g2, tp) then return true end
		end
	end
	return false
end

function s.tfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsFaceup()
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.tfilter,nil,e)
	if #g==0 then return end
	local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,g,tp)
	if #xyzg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sel=xyzg:Select(tp,1,1,nil)
	if #sel==0 then return end
	local xyz=sel:GetFirst()
	if xyz then
		Duel.XyzSummon(tp,xyz,nil,g)
	end
end

function s.thfilter(c)
	return c:IsSetCard(0xf11) and c:IsType(TYPE_SPELL) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
