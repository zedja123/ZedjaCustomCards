--Lavoisier Bertha
local s,id,o=GetID()
function c270000303.initial_effect(c)
	-- Pendulum Summon restriction
	Pendulum.AddProcedure(c)
	
	-- Cannot Pendulum Summon except "Lavoisier" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.pendlimit)
	c:RegisterEffect(e1)
	
	-- Destroy this card to add 1 "Lavoisier" card from GY to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,{id,3})
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)

	-- Monster Effect: Destroy 1 card from your hand; Add 1 "Lavoisier" Spell/Trap
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,4})
	e3:SetTarget(s.sthtg)
	e3:SetOperation(s.stop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
-- Shuffle and spsummon with = shuffled
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,{id,5})
	e6:SetCost(s.spcost3)
	e6:SetTarget(s.sptg3)
	e6:SetOperation(s.spop3)
	c:RegisterEffect(e6)
	-- Special Summon "Lavoisier" Pendulum Monster
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,1))
	e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1, {id,6})
	e7:SetTarget(s.sptg)
	e7:SetOperation(s.spop)
	-- While a Link monster points to this card, that card gains the effect
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e8:SetRange(LOCATION_MZONE)
	e8:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e8:SetTarget(s.eftg)
	e8:SetLabelObject(e7)
	c:RegisterEffect(e8)
end
function s.eftg(e,c)
	return c:GetLinkedGroup():IsContains(e:GetHandler())
end

-- Pendulum Summon restriction
function s.pendlimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsSetCard(0xf13) and (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end

-- Cost: Destroy this card
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable() end
	Duel.Destroy(e:GetHandler(),REASON_COST)
end

-- Target 1 "Lavoisier" card in the GY
function s.thfilter(c)
	return c:IsSetCard(0xf13) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

-- Add the targeted card to the hand
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end

-- Monster Effect: Destroy 1 card from your hand; Add 1 "Lavoisier" Spell/Trap
function s.sthfilter(c)
	return c:IsSetCard(0xf13) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end

function s.sthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sthfilter,tp,LOCATION_DECK,0,1,nil) 
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.stop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=Duel.SelectMatchingCard(tp,s.sthfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #sg>0 then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end

-- Shuffle and spsummon with = shuffled

function s.shfilter(c)
	return c:IsSetCard(0xf13) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost() and c:IsFaceup()
end
function s.spfilter1(c,e,tp,ct,g)
	return c:IsSetCard(0xf13) and c:IsType(TYPE_LINK) and c:IsLink(ct)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		and Duel.GetLocationCountFromEx(tp,tp,g,c)>0
end
function s.spcost3(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.shfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,nil)
	local nums={}
	for i=1,#g do
		if Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,i,g) then
			table.insert(nums,i)
		end
	end
	if chk==0 then return #nums>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	local ct=Duel.AnnounceNumber(tp,table.unpack(nums))
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local rg=g:Select(tp,ct,ct,nil)
	Duel.SendtoDeck(rg,tp,SEQ_DECKSHUFFLE,REASON_COST)
	e:SetLabel(ct)
end
function s.sptg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end --existence of card to summon checked in cost
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop3(e,tp,eg,ep,ev,re,r,rp)
	--special Summon
	local ct=e:GetLabel()
	if not ct then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,ct)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- Filter function for "Lavoisier" Pendulum monsters in the GY or Extra Deck
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xf13) and c:IsType(TYPE_PENDULUM) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- Target function for Special Summon
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end

-- Operation function for Special Summon
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- Negate the effects of the Special Summoned monster
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
		end
	end
end