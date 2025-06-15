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

function s.validGroup(g,tp)
	local n=#g
	if n==1 then
		local c=g:GetFirst()
		return c:IsType(TYPE_XYZ) and c:IsSetCard(0xf11) and c:GetRank()<=4
			and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,g,tp)
	elseif n==2 then
		for tc in aux.Next(g) do
			if tc:IsType(TYPE_XYZ) then return false end
		end
		return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,g,tp)
	end
	return false
end

function s.xyzfilter(c,mg,tp)
	return c:IsSetCard(0xf11) and c:IsXyzSummonable(nil,mg,1,2) and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil,e)

	if chk==0 then
		for tc1 in mg:Iter() do
			local solo=Group.FromCards(tc1)
			if s.validGroup(solo,tp) then return true end
			for tc2 in mg:Iter() do
				if tc1~=tc2 then
					local pair=Group.FromCards(tc1,tc2)
					if s.validGroup(pair,tp) then return true end
				end
			end
		end
		return false
	end

	-- Step 1: Build set of all monsters involved in at least one valid combo
	local validPool=Group.CreateGroup()

	-- Check all solos
	for tc in mg:Iter() do
		if s.validGroup(Group.FromCards(tc),tp) then
			validPool:AddCard(tc)
		end
	end

	-- Check all pairs
	for tc1 in mg:Iter() do
		for tc2 in mg:Iter() do
			if tc1~=tc2 then
				local pair=Group.FromCards(tc1,tc2)
				if s.validGroup(pair,tp) then
					validPool:AddCard(tc1)
					validPool:AddCard(tc2)
				end
			end
		end
	end

	if #validPool==0 then return false end

	-- Step 2: Select first target from validPool
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local first=validPool:Select(tp,1,1,nil):GetFirst()
	if not first then return end

	-- Step 3: Try solo
	if s.validGroup(Group.FromCards(first),tp) then
		Duel.SetTargetCard(first)
		return
	end

	-- Step 4: Force valid second from valid pairs
	local secondPool=Group.CreateGroup()
	for tc in validPool:Iter() do
		if tc~=first then
			local pair=Group.FromCards(first,tc)
			if s.validGroup(pair,tp) then
				secondPool:AddCard(tc)
			end
		end
	end

	if #secondPool==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local second=secondPool:Select(tp,1,1,nil):GetFirst()
	Duel.SetTargetCard(Group.FromCards(first,second))
end



function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or #tg==0 then return end
	local matGroup=tg:Filter(Card.IsRelateToEffect,nil,e)
	if #matGroup==0 then return end
	s.xyzSummon(tp,matGroup)
end

-- Xyz Summon helper
function s.xyzSummon(tp,matGroup)
	if not matGroup or #matGroup==0 then return end
	local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,matGroup,tp)
	if #xyzg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sel=xyzg:Select(tp,1,1,nil)
	if #sel==0 then return end
	local xyz=sel:GetFirst()
	if xyz then
		Duel.XyzSummon(tp,xyz,nil,matGroup)
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
