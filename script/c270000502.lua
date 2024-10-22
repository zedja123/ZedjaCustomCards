--Milacresy Destrollunism - Parsephin
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon from GY by sending this card and 1 other card from hand to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1, {id, 1})
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Banish 3 cards and Special Summon a "Milacresy" monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1, {id, 2})
	e2:SetTarget(s.bantg)
	e2:SetOperation(s.banop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)

	-- Prevent "Milacresy" monsters from being Tributed
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0)) -- Effect description
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING) -- Trigger when a chain is created
	e4:SetRange(LOCATION_GRAVE) -- This effect can be used from the GY
	e4:SetCondition(s.condition) -- Condition to activate the effect
	e4:SetCost(s.cost) -- Cost to activate the effect
	e4:SetOperation(s.operation) -- Operation to perform when effect is activated
	c:RegisterEffect(e4)
end

-- Cost: Send this card and 1 other card from hand to GY
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) and Duel.IsMainPhase() end
end

-- Target: Special Summon this card from GY
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

-- Operation: Special Summon this card from GY
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_DISCARD)
	Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_GRAVE) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- Target for banishing 3 cards from the Deck
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=4 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,4,tp,LOCATION_DECK)
end

-- Operation: Banish the top 3 cards and Special Summon a "Milacresy" monster
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<4 then return end
	local g=Duel.GetDecktopGroup(tp,4)
	Duel.DisableShuffleCheck()
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)==4 then
		if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,nil,e,tp)
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED+LOCATION_GRAVE,0,1,1,nil,e,tp)
			if #sg>0 then
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
-- Filter for "Milacresy" monster Special Summon
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xf16) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- Check if the opponent activated a card effect
	return ep~=tp and re:IsActivated() -- Opponent activated a card effect
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST) -- Banish the card as cost
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- Prevent "Milacresy" monsters from being Tributed until the end of this Chain
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)-- Field effect
	e1:SetCode(EFFECT_CANNOT_RELEASE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET) -- Apply to player
	e1:SetTargetRange(0,1) -- Target the player controlling "Milacresy" monsters
	e1:SetTarget(function(e,c) return c:IsSetCard(0xf16) and c:IsType(TYPE_MONSTER) end) -- Target "Milacresy" monsters
	e1:SetReset(RESET_CHAIN) -- Reset at the end of the chain -- Prevent Tributing
	Duel.RegisterEffect(e1,tp) -- Register the effect
end